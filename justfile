default:
    echo 'Hello, world!'

# Update a specific flake input
update input:
    nix flake lock --update-input {{input}} --commit-lock-file

build-vm:
    nixos-rebuild build-vm --flake .#vm --print-build-logs

run-vm: build-vm
    QEMU_OPTS="$QEMU_OPTS_WL" result/bin/run-nixos-vm

update-vim-plugins:
    #!/bin/sh
    # Use local nixpkgs if available
    nixpkgs="$HOME/Dev/nixpkgs"
    # copy nixpkgs from local checkout
    if [ ! -d "$nixpkgs" ]; then
        nixpkgs="$(mktemp -d)"
        cp -r /nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs/. "$nixpkgs"
        cd "$nixpkgs"
        git init .
        git add .
        git commit -m 'dummy commit'
        cd -
    fi
    # update vim plugins
    nix run nixpkgs#vimPluginsUpdater -- --proc=1 --nixpkgs "$nixpkgs" --no-commit -i ./nvim/extraPlugins/plugins -o ./nvim/extraPlugins/generated.nix update
    # format the generated output
    nix fmt ./nvim/extraPlugins/generated.nix

# Amend Update flake.lock PR
flake-pr:
    git branch -D update_flake_lock_action || echo "no previous update branch"
    gix fetch -r origin
    git switch update_flake_lock_action
    git commit --amend --no-edit
    git push origin update_flake_lock_action --force-with-lease
