# pyright: strict, reportAny=false
from dataclasses import dataclass
import json
import subprocess
from typing import Self
import typing
import click


def expect[T](typ: type[T], value: object) -> T:
    if not isinstance(value, typ):
        raise ValueError(
            f"expected value to be of type {typ} but was of type {type(value)}"
        )
    return value


@dataclass(slots=True)
class PWNodeProps:
    object_id: int
    node_description: str
    node_name: str
    media_class: str

    @classmethod
    def from_json(cls, data: dict[str, object]) -> Self:
        return cls(
            object_id=expect(int, data["object.id"]),
            node_description=expect(str, data.get("node.description", "(unknown)")),
            node_name=expect(str, data["node.name"]),
            media_class=expect(str, data.get("media.class", "(unknown)")),
        )


@dataclass(slots=True)
class PWNodeInfo:
    props: PWNodeProps

    @classmethod
    def from_json(cls, data: dict[str, object]) -> Self:
        props = typing.cast(dict[str, object], expect(dict, data["props"]))
        return cls(PWNodeProps.from_json(props))


@dataclass(slots=True)
class PWNode:
    node_type: str
    info: PWNodeInfo | None

    @classmethod
    def from_json(cls, data: dict[str, object]) -> Self:
        info = data.get("info", None)
        if info is not None:
            info = PWNodeInfo.from_json(
                typing.cast(dict[str, object], expect(dict, info))
            )
        return cls(node_type=expect(str, data["type"]), info=info)


@dataclass(slots=True)
class AudioDevice:
    id: int
    name: str
    volume: float
    muted: bool
    default: bool

    @staticmethod
    def get_volume(id: int | str) -> tuple[float, bool]:
        wpctl_output = subprocess.run(
            ["wpctl", "get-volume", str(id)],
            encoding="UTF-8",
            check=True,
            capture_output=True,
        )
        match wpctl_output.stdout.strip().split(sep=" "):
            case ["Volume:", value]:
                return (float(value), False)
            case ["Volume:", value, "[MUTED]"]:
                return (float(value), True)
            case _:
                raise ValueError(f"Unexpected wpctl output: {wpctl_output.stdout}")

    @classmethod
    def from_pw_node(cls, node: PWNode, default: str) -> Self:
        if node.info is None:
            raise ValueError(f"Node is not a valid audio device {node}")

        id = node.info.props.object_id
        volume, muted = cls.get_volume(id)

        return cls(
            id=id,
            name=node.info.props.node_description,
            volume=volume,
            muted=muted,
            default=node.info.props.node_name == default,
        )

    def menu_item(self) -> str:
        id = f"id={self.id:<3}"

        if self.default:
            id = f"[{id}]"
        else:
            id = f" {id} "

        if self.muted:
            return f"{id} {self.volume:>4.0%} [MUTED] {self.name}"
        else:
            return f"{id} {self.volume:>4.0%} {self.name}"


def get_nodes(data: list[dict[str, object]]) -> list[PWNode]:
    def is_audio_node(node: object) -> bool:
        if not isinstance(node, dict):
            return False

        node = typing.cast(dict[str, object], node)
        if node["type"] != "PipeWire:Interface:Node":
            return False
        info = node.get("info", None)
        if info is None or not isinstance(info, dict):
            return False
        info = typing.cast(dict[str, object], info)
        props = info.get("props", None)
        if props is None or not isinstance(props, dict):
            return False
        props = typing.cast(dict[str, object], props)
        if (media_class := props.get("media.class", None)) is not None:
            return isinstance(media_class, str) and media_class.startswith("Audio")
        return False

    return [
        PWNode.from_json(typing.cast(dict[str, object], expect(dict, node)))
        for node in data
        if is_audio_node(node)
    ]


def pw_dump() -> list[dict[str, object]]:
    dump_output = subprocess.run(
        ["pw-dump"], encoding="UTF-8", check=True, capture_output=True
    )
    data = json.loads(dump_output.stdout)
    return typing.cast(list[dict[str, object]], expect(list, data))


def get_defaults_metadata(data: list[dict[str, object]]) -> list[dict[str, object]]:
    return typing.cast(
        list[dict[str, object]],
        expect(
            list,
            next(
                node
                for node in data
                if node["type"] == "PipeWire:Interface:Metadata"
                and expect(dict, node["props"])["metadata.name"] == "default"
            )["metadata"],
        ),
    )


def get_sinks() -> list[AudioDevice]:
    data = pw_dump()
    default = next(
        typing.cast(dict[str, str], expect(dict, data["value"]))["name"]
        for data in get_defaults_metadata(data)
        if data["key"] == "default.audio.sink"
    )
    return [
        AudioDevice.from_pw_node(node, default)
        for node in get_nodes(data)
        if node.info is not None and node.info.props.media_class == "Audio/Sink"
    ]


def get_sources() -> list[AudioDevice]:
    data = pw_dump()
    default = next(
        typing.cast(dict[str, str], expect(dict, data["value"]))["name"]
        for data in get_defaults_metadata(data)
        if data["key"] == "default.audio.source"
    )
    return [
        AudioDevice.from_pw_node(node, default)
        for node in get_nodes(data)
        if node.info is not None and node.info.props.media_class == "Audio/Source"
    ]


@click.group(name="audiomenu")
def main() -> None:
    pass


def select(options: list[str], prompt: str) -> int | None:
    menu_output = subprocess.run(
        ["fuzzel", "--dmenu", f"--prompt={prompt}"],
        input="\n".join(options),
        encoding="UTF-8",
        capture_output=True,
    )
    if menu_output.returncode == 2:
        return None
    menu_output.check_returncode()
    selected = menu_output.stdout.rstrip()
    return options.index(selected)


@main.command()
def select_sink() -> None:
    devices = get_sinks()
    selected = select([device.menu_item() for device in devices], prompt="Select Sink>")
    if selected is None:
        click.echo("No sink selected")
        return

    device = devices[selected]
    _ = subprocess.run(["wpctl", "set-default", str(device.id)], check=True)


@main.command()
def select_source() -> None:
    devices = get_sources()
    selected = select(
        [device.menu_item() for device in devices], prompt="Select Source>"
    )
    if selected is None:
        click.echo("No source selected")
        return

    device = devices[selected]
    _ = subprocess.run(["wpctl", "set-default", str(device.id)], check=True)


if __name__ == "__main__":
    main()
