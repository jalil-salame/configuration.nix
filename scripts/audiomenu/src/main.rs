use std::{
    fmt::{Display, Write as _},
    io::{Read, Write as _},
    process::{Command, Stdio},
};

use clap::Parser;
use duct::cmd;
use miette::{bail, Context, IntoDiagnostic, Result};
use serde::Deserialize;

fn main() -> Result<()> {
    miette::set_panic_hook();
    Opts::parse().run()
}

/// fuzzel script to select the default audio device for pipewire+wireplumber
#[derive(Debug, Parser)]
struct Opts {
    #[clap(subcommand)]
    cmd: Cmd,
}

impl Opts {
    fn run(self) -> Result<()> {
        self.cmd.run()
    }
}

#[derive(Debug, clap::Subcommand)]
enum Cmd {
    /// Select audio sink (speakers/headphones)
    SelectSink,
    /// Select audio source (microphone)
    SelectSource,
}

impl Cmd {
    fn run(self) -> Result<()> {
        let id = match self {
            Cmd::SelectSink => {
                let devices = get_sinks().wrap_err("failed to get sinks")?;
                let selected = select(
                    devices.iter().map(|dev| dev.name.as_ref()),
                    Some("Select input>"),
                )
                .wrap_err("failed to select a default sink")?;
                if selected.is_empty() {
                    eprintln!("did not select a device");
                    return Ok(());
                }
                let Some(dev) = devices.into_iter().find(|dev| dev.name == selected) else {
                    bail!("couldn't find a device matching `{selected}`");
                };
                dev.id
            }
            Cmd::SelectSource => {
                let devices = get_sources().wrap_err("failed to get sinks")?;
                let selected = select(
                    devices.iter().map(|dev| dev.name.as_ref()),
                    Some("Select output>"),
                )
                .wrap_err("failed to select a default source")?;
                if selected.is_empty() {
                    eprintln!("did not select a device");
                    return Ok(());
                }
                let Some(dev) = devices.into_iter().find(|dev| dev.name == selected) else {
                    bail!("couldn't find a device matching `{selected}`");
                };
                dev.id
            }
        };
        cmd!("wpctl", "set-default", id.to_string())
            .run()
            .map(drop)
            .into_diagnostic()
            .wrap_err("failed to set default input")
    }
}

#[derive(Debug, Deserialize)]
struct PWNode {
    #[serde(rename = "type")]
    node_type: Box<str>,
    #[serde(default)]
    info: PWNodeInfo,
    // json ignores the rest of the fields by default
}

#[derive(Debug, Deserialize, Default)]
struct PWNodeInfo {
    props: PWNodeProps,
    // json ignores the rest of the fields by default
}

#[derive(Debug, Deserialize, Default)]
struct PWNodeProps {
    #[serde(rename = "object.id")]
    object_id: u32,
    #[serde(rename = "node.description", default)]
    node_description: Box<str>,
    #[serde(rename = "media.class", default)]
    media_class: Box<str>,
    // json ignores the rest of the fields by default
}

struct AudioDevice<S> {
    id: u32,
    name: Box<str>,
    _side: S,
}

/// Output (e.g. speakers)
struct AudioSink;

/// Input (e.g. microphone)
struct AudioSource;

fn get_sinks() -> Result<Vec<AudioDevice<AudioSink>>> {
    get_devices()
}

fn get_sources() -> Result<Vec<AudioDevice<AudioSource>>> {
    get_devices()
}

fn get_devices<S>() -> Result<Vec<AudioDevice<S>>>
where
    AudioDevice<S>: TryFrom<PWNode>,
{
    Ok(get_nodes()?
        .into_iter()
        .filter_map(|node| AudioDevice::<S>::try_from(node).ok())
        .collect())
}

impl TryFrom<PWNode> for AudioDevice<AudioSource> {
    type Error = miette::Report;

    fn try_from(value: PWNode) -> std::result::Result<Self, Self::Error> {
        if value.node_type.as_ref() != "PipeWire:Interface:Node" {
            bail!(
                "invalid type: `{}`, expected `PipeWire:Interface:Node`",
                value.node_type
            )
        }
        let class = value.info.props.media_class;
        match class.as_ref() {
            "Audio/Source" => Ok(Self {
                id: value.info.props.object_id,
                name: value.info.props.node_description,
                _side: AudioSource,
            }),
            _ => bail!("invalid media.class: `{class}`, expected `Audio/Source`"),
        }
    }
}

impl TryFrom<PWNode> for AudioDevice<AudioSink> {
    type Error = miette::Report;

    fn try_from(value: PWNode) -> std::result::Result<Self, Self::Error> {
        if value.node_type.as_ref() != "PipeWire:Interface:Node" {
            bail!(
                "invalid type: `{}`, expected `PipeWire:Interface:Node`",
                value.node_type
            )
        }
        let class = value.info.props.media_class;
        match class.as_ref() {
            "Audio/Sink" => Ok(Self {
                id: value.info.props.object_id,
                name: value.info.props.node_description,
                _side: AudioSink,
            }),
            _ => bail!("invalid media.class: `{class}`, expected `Audio/Sink`"),
        }
    }
}

fn get_nodes() -> Result<Vec<PWNode>> {
    let dump = cmd!("pw-dump")
        .read()
        .into_diagnostic()
        .wrap_err("failed to get devices with pw-dump")?;
    serde_json::from_str(&dump)
        .into_diagnostic()
        .wrap_err("failed to parse pw-dump output")
}

fn select<T, It>(options: It, prompt: Option<&str>) -> Result<Box<str>>
where
    T: Display,
    It: IntoIterator<Item = T>,
{
    let append_line = |mut s: String, it| {
        writeln!(s, "{it}").unwrap();
        s
    };
    let options = options.into_iter().fold(String::new(), append_line);
    let mut menu = Command::new("fuzzel");
    menu.arg("--dmenu");
    if let Some(prompt) = prompt {
        menu.arg(format!("--prompt={prompt}"));
    }
    Ok(pipe_to_stdin_and_return_stdout(&mut menu, options)?
        .trim()
        .into())
}

fn pipe_to_stdin_and_return_stdout(cmd: &mut Command, data: impl Display) -> Result<String> {
    let mut child = cmd
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .into_diagnostic()
        .wrap_err_with(|| format!("failed to run {cmd:?}"))?;
    let mut stdin = child.stdin.take().expect("stdin not piped");
    write!(stdin, "{data}")
        .into_diagnostic()
        .wrap_err("failed to send data to process' stdin")?;
    drop(stdin);
    let mut stdout = child.stdout.take().expect("stdout not piped");
    let mut buf = String::new();
    stdout
        .read_to_string(&mut buf)
        .into_diagnostic()
        .wrap_err("failed to retrieve output from process")?;
    Ok(buf)
}
