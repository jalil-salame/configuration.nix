{
  nvim-config,
  stylix ? null,
}:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.jhome;
  devcfg = cfg.dev;
in
{
  imports =
    [
      nvim-config
      ./options.nix
      ./gui
      ./users.nix
    ]
    ++ lib.optionals (stylix != null) [
      stylix.homeManagerModules.stylix
      { stylix.image = cfg.sway.background; }
    ];

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.styling.enable) { stylix.enable = true; })
    (lib.mkIf cfg.enable {
      programs = {
        # Better cat (bat)
        bat = {
          enable = true;
          config = {
            # Disable headers and numbers
            style = "plain";
            theme = lib.mkForce "gruvbox-dark";
          };
        };
        # Direnv
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        # ls replacement
        eza = {
          enable = true;
          git = true;
          icons = true;
        };
        # GnuPG
        gpg = {
          enable = true;
          homedir = "${config.xdg.dataHome}/gnupg";
        };
        # Mail client
        himalaya.enable = true;
        # Another shell
        nushell.enable = true;
        # Password manager
        password-store = {
          enable = true;
          package = pkgs.pass-nodmenu;
          settings.PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass";
        };
        # SSH
        ssh.enable = true;
        # cd replacement
        zoxide.enable = true;
        # Shell
        zsh = {
          enable = true;
          autosuggestion.enable = true;
          enableCompletion = true;
          autocd = true;
          dotDir = ".config/zsh";
          history.path = "${config.xdg.dataHome}/zsh/zsh_history";
          syntaxHighlighting.enable = true;
        };
      };
      services = {
        # GPG Agent
        gpg-agent = {
          enable = true;
          maxCacheTtl = 86400;
          pinentryPackage = if config.jhome.gui.enable then pkgs.pinentry-qt else pkgs.pinentry-curses;
          extraConfig = "allow-preset-passphrase";
        };
        # Spotifyd
        spotifyd = {
          inherit (config.jhome.gui) enable;
          settings.global = {
            device_name = config.jhome.hostName;
            device_type = "computer";
            backend = "pulseaudio";
            zeroconf_port = 2020;
          };
        };
      };
      home = {
        stateVersion = "22.11";
        # Extra packages
        packages = [
          pkgs.gopass
          pkgs.sshfs
          pkgs.gitoxide
        ];
        # Extra variables
        sessionVariables = {
          CARGO_HOME = "${config.xdg.dataHome}/cargo";
          RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
          GOPATH = "${config.xdg.dataHome}/go";
        };
        shellAliases = {
          # Verbose Commands
          cp = "cp --verbose";
          ln = "ln --verbose";
          mv = "mv --verbose";
          mkdir = "mkdir --verbose";
          rename = "rename --verbose";
          rm = "rm --verbose";
          # Add Color
          grep = "grep --color=auto";
          ip = "ip --color=auto";
          # Use exa/eza
          tree = "eza --tree";
        };
      };
      # XDG directories
      xdg = {
        enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
        };
      };
    })
    (lib.mkIf (cfg.enable && devcfg.enable) {
      home = {
        sessionVariables.MANPAGER = lib.optionalString devcfg.neovimAsManPager "nvim -c 'Man!' -o -";
        packages = devcfg.extraPackages;
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
          settings = {
            ui.pager = "bat";
          };
        };
      };
    })
    (lib.mkIf (cfg.enable && devcfg.enable && devcfg.rust.enable) {
      home.packages = [ pkgs.rustup ] ++ devcfg.rust.extraPackages;
      # Background code checker (for Rust)
      programs.bacon = {
        enable = true;
        settings = {
          export = {
            enabled = true;
            path = ".bacon-locations";
            line_format = "{kind} {path}:{line}:{column} {message}";
          };
        };
      };
    })
  ];
}
