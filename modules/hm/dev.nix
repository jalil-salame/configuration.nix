{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.jhome.dev;
  nvimFormatters = builtins.mapAttrs (
    name: value: value.command
  ) config.programs.nixvim.plugins.conform-nvim.settings.formatters;
  jjFormatters =
    let
      ext_to_glob = ext: "glob:'**/*.${ext}'";
      exts = builtins.map ext_to_glob;
    in
    {
      fish = cmd: {
        command = [ cmd ];
        patterns = exts [ "fish" ];
      };
      clang_format = cmd: {
        command = [
          cmd
          "--assume-filename=$path"
        ];
        patterns = exts [
          "c"
          "cc"
          "cpp"
          "h"
          "hh"
          "hpp"
        ];
      };
      nixfmt = cmd: {
        command = [
          cmd
          "--filename=$path"
        ];
        patterns = exts [ "nix" ];
      };
      shfmt = cmd: {
        command = [
          cmd
          "--filename"
          "$path"
          "-"
        ];
        patterns = exts [
          "sh"
          "bash"
        ];
      };
      stylua = cmd: {
        command = [
          cmd
          "--stdin-filepath=$path"
          "-"
        ];
        patterns = exts [ "lua" ];
      };
      taplo = cmd: {
        command = [
          cmd
          "format"
          "--stdin-filepath=$path"
          "-"
        ];
        patterns = exts [ "toml" ];
      };
      yamlfmt = cmd: {
        command = [
          cmd
          "-in"
        ];
        patterns = exts [
          "yaml"
          "yml"
        ];
      };
    };
in
{
  config =
    lib.flip lib.pipe
      [
        lib.mkMerge
        (lib.mkIf (config.jhome.enable && cfg.enable))
      ]
      [
        (lib.mkIf cfg.rust.enable {
          home.packages = [ pkgs.rustup ] ++ cfg.rust.extraPackages;
        })
        {
          home = {
            sessionVariables.MANPAGER = lib.optionalString cfg.neovimAsManPager "nvim -c 'Man!' -o -";
            packages = cfg.extraPackages;
          };

          programs = {
            fish.functions = {
              # Useful for home-manager config testing (quickly modify the config source)
              edit-nix-link = {
                description = "Create a copy of a nix file for editing";
                argumentNames = [ "file" ];
                body = # fish
                  ''
                    test (count $argv) -eq 1
                    or begin
                        echo "ERROR: exactly one argument needed, got" (count $argv) >&2
                        return 1
                    end

                    realpath $file >/dev/null
                    or begin
                        echo "ERROR: couldn't find $file" >&2
                        return 1
                    end

                    string match --quiet --regex '^/nix/store' (realpath $file)
                    or begin
                        echo "ERROR: $file is not a symlink to the nix store" >&2
                        return 1
                    end

                    mv $file "$file.bak"
                    and begin
                        install --mode 644 "$file.bak" $file
                        or mv "$file.bak" $file
                    end
                    or begin
                        echo "ERROR: failed to create editable file" >&2
                        return 1
                    end

                    and if type --query $VISUAL
                        $VISUAL $file
                    else if type --query $EDITOR
                        $EDITOR $file
                    end
                  '';
              };
              unedit-nix-link = {
                description = "Restore backup from edit-nix-link";
                argumentNames = [ "file" ];
                body = # fish
                  ''
                    test (count $argv) -eq 1
                    or begin
                        echo "ERROR: exactly one argument needed, got" (count $argv) >&2
                        return 1
                    end

                    realpath $file.bak >/dev/null
                    or begin
                        echo "ERROR: couldn't find backup for $file at $file.bak" >&2
                        return 1
                    end

                    string match --quiet --regex '^/nix/store' (realpath "$file.bak")
                    or begin
                        echo "ERROR: backup $file.bak is not a symlink to the nix store" >&2
                        return 1
                    end

                    mv "$file.bak" $file
                    or begin
                        echo "ERROR: failed to restore backup file" >&2
                        return 1
                    end
                  '';
              };
            };
            difftastic = {
              enable = true;
              git.enable = true;
              options.background = "dark";
            };
            # Github CLI
            gh.enable = true;
            gh-dash.enable = true;
            # Git
            git = {
              enable = true;
              lfs.enable = true;
              settings = {
                # Add diff to the commit message editor
                commit.verbose = true;
                # Improve submodule diff
                diff.submodule = "log";
                # Set the default branch name for new branches
                init.defaultBranch = "main";
                # Better conflicts (also shows parent commit state)
                merge.conflictStyle = "zdiff3";
                # Do not create merge commits when pulling (rebase but abort on conflict)
                pull.ff = "only";
                # Use `--set-upstream` if the remote does not have the branch
                push.autoSetupRemote = true;
                rebase = {
                  # If there are uncommitted changes, stash them before rebasing
                  autoStash = true;
                  # If there are fixup! commits, squash them while rebasing
                  autoSquash = true;
                };
                # Enable ReReRe (Reuse Recovered Resolution) auto resolve previously resolved conflicts
                rerere.enabled = true;
                # Improve submodule status
                status.submoduleSummary = true;
              };
            };
            lazygit.enable = true;
            # Jujutsu (alternative DVCS (git-compatible))
            jujutsu = {
              enable = lib.mkDefault true;
              settings = {
                fix.tools = builtins.mapAttrs (tool: cmd: jjFormatters.${tool} cmd) nvimFormatters;
                # mimic git commit --verbose by adding a diff
                templates.draft_commit_description = ''
                  concat(
                    description,
                    "\n",
                    surround(
                      "\nJJ: This commit contains the following changes:\n", "",
                      indent("JJ:     ", diff.summary()),
                    ),
                    surround(
                      "JJ: ignore-rest\n", "",
                      diff.git(),
                    ),
                  )
                '';
              };
            };

            # configure zellij without enabling it
            zellij.settings = {
              show_startup_tips = false; # disable the startup tips dialogue
              # Set default shell
              default_shell =
                if config.programs.fish.enable then
                  "fish"
                else if config.programs.zsh.enable then
                  "zsh"
                else
                  "bash";
            };
          };
        }
      ];
}
