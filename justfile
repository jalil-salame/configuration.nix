default:
    echo 'Hello, world!'

# Update a specific flake input
update input:
    nix flake lock --update-input {{input}} --commit-lock-file

# Amend Update flake.lock PR
flake-pr:
    git branch -D update_flake_lock_action || echo "no previous update branch"
    gix fetch -r origin
    git switch update_flake_lock_action
    git commit --amend --no-edit
    git push origin update_flake_lock_action --force-with-lease
