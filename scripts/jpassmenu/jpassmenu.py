from os import environ
from pathlib import Path
import subprocess
import click


def select(options: list[str]) -> int | None:
    menu_output = subprocess.run(
        ["fuzzel", "--dmenu"],
        input="\n".join(options),
        encoding="UTF-8",
        capture_output=True,
    )
    if menu_output.returncode == 2:
        return None
    menu_output.check_returncode()
    selected = menu_output.stdout.rstrip()
    return options.index(selected)


@click.command(
    "jpassmenu", context_settings={"show_default": True, "max_content_width": 120}
)
@click.option(
    "--type",
    "typeit",
    help="Type the password using ydotool instead of copying it to the clipboard",
)
@click.option(
    "--store-dir",
    type=click.Path(exists=True, file_okay=False, path_type=Path),
    envvar="PASSWORD_STORE_DIR",
    default=Path("~/.password-store"),
)
@click.option(
    "--pass-bin",
    default="pass",
    help="Path to the pass binary\n\nNeeds to support `pass show` and `pass show --clip`",
)
@click.option(
    "--menu-bin", default="fuzzel", help="Path to the dmenu compatible menu binary"
)
@click.argument("menu_args", nargs=-1)
def main(
    typeit: bool, store_dir: Path, pass_bin: str, menu_bin: str, menu_args: list[str]
) -> None:
    menu_args = (
        ["--dmenu"] if not menu_args and menu_bin.endswith("fuzzel") else menu_args
    )
    store_dir = store_dir.expanduser().absolute()
    # Get all files in store_dir
    secrets = (
        dirpath / fname
        for dirpath, _dirnames, filenames in store_dir.walk()
        for fname in filenames
    )
    # Filter for files ending in .gpg and strip the extension
    secrets = (
        secret.with_suffix("")
        for secret in secrets
        if secret.is_file() and secret.suffix == ".gpg"
    )
    # Make the paths relative to store_dir and turn to strings
    secrets = sorted(str(secret.relative_to(store_dir)) for secret in secrets)

    if not secrets:
        click.secho(f"No valid entries found in {store_dir}", err=True, fg="red")

    selected = select(secrets)
    if selected is None:
        click.echo("No secret selected")
        return
    selected = secrets[selected]

    # If PASSWORD_STORE_DIR and --store-dir disagree, set PASSWORD_STORE_DIR to --store-dir
    env_store = (
        Path(environ.get("PASSWORD_STORE_DIR", default="~/.password-store"))
        .expanduser()
        .absolute()
    )
    if store_dir != env_store:
        environ["PASSWORD_STORE_DIR"] = str(store_dir)

    pass_cmd = (
        [pass_bin, "show", selected]
        if typeit
        else [pass_bin, "show", "--clip", selected]
    )

    pass_output = subprocess.run(
        pass_cmd,
        encoding="UTF-8",
        check=True,
        capture_output=typeit,
    )
    if not typeit:
        return

    pass_entry = pass_output.stdout
    secret = pass_entry.splitlines()[0].strip()

    _ = subprocess.run(
        ["ydotool", "type", "--file", "-"],
        input=secret,
        encoding="UTF-8",
        check=True,
    )


if __name__ == "__main__":
    main()
