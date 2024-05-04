default:
    echo 'Hello, world!'

# Update a specific flake input
update input:
    nix flake lock --update-input {{input}} --commit-lock-file

build-vm:
    nixos-rebuild build-vm --flake .#vm --print-build-logs

run-vm: build-vm
    QEMU_OPTS="$QEMU_OPTS_WL" result/bin/run-nixos-vm

# Amend Update flake.lock PR
flake-pr:
    git branch -D update_flake_lock_action || echo "no previous update branch"
    gix fetch -r origin
    git switch update_flake_lock_action
    git commit --amend --no-edit
    git push origin update_flake_lock_action --force-with-lease
