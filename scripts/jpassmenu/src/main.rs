use std::{
    ffi::OsStr,
    fmt::Write as _,
    path::{Path, PathBuf},
};

use clap::Parser;
use duct::cmd;
use miette::{bail, ensure, Context, IntoDiagnostic, Result};

fn main() -> Result<()> {
    miette::set_panic_hook();
    env_logger::builder()
        .filter_level(log::LevelFilter::Info)
        .parse_default_env()
        .try_init()
        .into_diagnostic()?;
    Opts::parse().run()
}

impl Opts {
    fn run(self) -> Result<()> {
        log::debug!("parsed opts {self:?}");
        let Self {
            typeit,
            store_dir,
            pass_bin,
            menu_bin,
            menu_args,
        } = self;
        let store_dir = resolve_home(store_dir);
        // Search paths
        log::info!("looking for entries in {}", store_dir.display());
        let mut paths = ignore::Walk::new(&store_dir)
            .filter_map(|entry| {
                let entry = entry.ok()?;
                if entry.file_type()?.is_file()
                    && entry.path().extension() == Some(OsStr::new("gpg"))
                {
                    let path = entry.path();
                    Some(
                        path.strip_prefix(&store_dir)
                            .unwrap_or(path)
                            .with_extension("")
                            .into_boxed_path(),
                    )
                } else {
                    None
                }
            })
            .collect::<Vec<Box<Path>>>();
        paths.sort_unstable();
        ensure!(
            !paths.is_empty(),
            "failed to find entries in {}",
            store_dir.display()
        );
        log::debug!("found entries: {paths:#?}");
        // Concatenate all paths
        let paths = paths
            .into_iter()
            .try_fold(String::new(), |mut acc, it| {
                writeln!(acc, "{}", it.display()).map(|_| acc)
            })
            .into_diagnostic()
            .wrap_err("preparing paths")?;
        // Show dynamic menu
        let selected = cmd(menu_bin, menu_args)
            .stdin_bytes(paths.as_bytes())
            .read()
            .into_diagnostic()
            .wrap_err("failed to run menu and retrieve the selected entry")?;
        let selected = selected.trim();
        if selected.is_empty() {
            bail!("no password entry selected");
        }
        // Prepare env dir
        let env_store = std::env::var_os("PASSWORD_STORE_DIR");
        let set_env = if let Some(env_store) = env_store {
            if store_dir != env_store {
                Some(store_dir)
            } else {
                None
            }
        } else if store_dir == Path::new("~/.password-store") {
            None
        } else {
            Some(store_dir)
        };
        // Prepare pass command
        let args = if typeit {
            vec!["show", selected]
        } else {
            vec!["show", "-c", selected]
        };
        let pass = cmd(pass_bin, args);
        let pass = if let Some(env) = set_env {
            pass.env("PASSWORD_STORE_DIR", env)
        } else {
            pass
        };
        // Copy password to clipboard
        if !typeit {
            pass.run()
                .into_diagnostic()
                .wrap_err("failed to copy password to clipboard")?;
            return Ok(());
        }
        // Retrieve password
        let pass_entry = pass
            .read()
            .into_diagnostic()
            .wrap_err("failed to retrieve password")?;
        let Some(password) = pass_entry.lines().next() else {
            bail!("failed to retrieve password or entry was empty");
        };
        // Type password with ydotool
        cmd("ydotool", &["type", "--file", "-"])
            .stdin_bytes(password.as_bytes())
            .run()
            .into_diagnostic()
            .wrap_err("failed to type password with ydotool")?;
        Ok(())
    }
}

#[derive(Debug, Parser)]
struct Opts {
    /// Type the password instead of copying it to the clipboard
    #[arg(long("type"))]
    typeit: bool,
    #[arg(long, env("PASSWORD_STORE_DIR"), default_value = "~/.password-store")]
    store_dir: PathBuf,
    /// Path to the pass binary
    ///
    /// Needs to support `pass show` and `pass show -c`
    #[arg(long, default_value = "pass")]
    pass_bin: String,
    /// Path to the dynamic menu binary
    #[arg(long, default_value = "fuzzel")]
    menu_bin: String,
    /// Args to the dynamic menu
    #[arg(long, default_value = "--dmenu")]
    menu_args: Vec<String>,
}

fn resolve_home(path: PathBuf) -> PathBuf {
    if let Ok(path) = path.strip_prefix("~") {
        if let Some(home) = std::env::var_os("HOME") {
            let mut home = PathBuf::from(home);
            home.push(path);
            return home;
        }
    }
    path
}
