{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.jhome.dev;
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

          # Github CLI
          programs = {
            gh.enable = true;
            gh-dash.enable = true;
            # Git
            git = {
              enable = true;
              difftastic = {
                enable = true;
                background = "dark";
              };
              lfs.enable = true;
              extraConfig = {
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
              enable = true;
              package = pkgs.unstable.jujutsu;
              settings = {
                ui.pager = "bat";
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
          };
        }
      ];
}
