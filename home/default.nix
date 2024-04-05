{
  overlays,
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
      # Apply overlays
      {
        nixpkgs = {
          inherit overlays;
        };
      }
      nvim-config
      ./options.nix
      ./gui
      ./users.nix
    ]
    ++ lib.optionals (stylix != null) [
      stylix.homeManagerModules.stylix
      {
        stylix.image = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/d4937c424fad79c1136a904599ba689fcf8d0fad/png/gruvbox-dark-rainbow.png";
          sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
        };
      }
    ];

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.bat = {
        # Better cat (bat)
        enable = true;
        config = {
          style = "plain"; # Disable headers and numbers
          theme = "gruvbox-dark"; # TODO: Follow light/dark polarity
        };
      };
      # Direnv
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
      # ls replacement
      programs.eza.enable = true;
      programs.eza.git = true;
      programs.eza.icons = true;
      # GnuPG
      programs.gpg.enable = true;
      programs.gpg.homedir = "${config.xdg.dataHome}/gnupg";
      # Mail client
      programs.himalaya.enable = true;
      # Another shell
      programs.nushell.enable = true;
      # Password manager
      programs.password-store.enable = true;
      programs.password-store.package = pkgs.pass-nodmenu;
      programs.password-store.settings.PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass";
      # SSH
      programs.ssh.enable = true;
      # cd replacement
      programs.zoxide.enable = true;
      # Shell
      programs.zsh.enable = true;
      programs.zsh.autosuggestion.enable = true;
      programs.zsh.enableCompletion = true;
      programs.zsh.autocd = true;
      programs.zsh.dotDir = ".config/zsh";
      programs.zsh.history.path = "${config.xdg.dataHome}/zsh/zsh_history";
      programs.zsh.syntaxHighlighting.enable = true;

      # GPG Agent
      services.gpg-agent.enable = true;
      services.gpg-agent.maxCacheTtl = 86400;
      services.gpg-agent.pinentryPackage =
        if config.jhome.gui.enable then pkgs.pinentry-qt else pkgs.pinentry-curses;
      services.gpg-agent.extraConfig = "allow-preset-passphrase";
      # Spotifyd
      services.spotifyd.enable = true;
      services.spotifyd.settings.global.device_name = config.jhome.hostName;
      services.spotifyd.settings.global.device_type = "computer";
      services.spotifyd.settings.global.backend = "pulseaudio";
      services.spotifyd.settings.global.zeroconf_port = 2020;

      home.stateVersion = "22.11";

      # Extra packages
      home.packages = [
        pkgs.gopass
        pkgs.sshfs
        pkgs.gitoxide
        pkgs.xplr
      ];

      # Extra variables
      home.sessionVariables = {
        CARGO_HOME = "${config.xdg.dataHome}/cargo";
        RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
        GOPATH = "${config.xdg.dataHome}/go";
      };
      home.shellAliases = {
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

      # XDG directories
      xdg.enable = true;
      xdg.userDirs.enable = true;
      xdg.userDirs.createDirectories = true;
    })
    (lib.mkIf (cfg.enable && devcfg.enable) {
      home = {
        sessionVariables.MANPAGER = lib.optionalString devcfg.neovimAsManPager "nvim -c 'Man!' -o -";
        packages = devcfg.extraPackages;
      };

      # Github CLI
      programs.gh.enable = true;
      programs.gh-dash.enable = true;
      # Git
      programs.git = {
        enable = true;
        difftastic.enable = true;
        difftastic.background = "dark";
        lfs.enable = true;
        # Add diff to the commit message editor
        extraConfig.commit.verbose = true;
        # Improve submodule diff
        extraConfig.diff.submodule = "log";
        # Set the default branch name for new branches
        extraConfig.init.defaultBranch = "main";
        # Better conflicts (also shows parent commit state)
        extraConfig.merge.conflictStyle = "zdiff3";
        # Do not create merge commits when pulling (rebase but abort on conflict)
        extraConfig.pull.ff = "only";
        # Use `--set-upstream` if the remote does not have the branch
        extraConfig.push.autoSetupRemote = true;
        # If there are uncommitted changes, stash them before rebasing
        extraConfig.rebase.autoStash = true;
        # If there are fixup! commits, squash them while rebasing
        extraConfig.rebase.autoSquash = true;
        # Enable ReReRe (Reuse Recovered Resolution) auto resolve previously resolved conflicts
        extraConfig.rerere.enabled = true;
        # Improve submodule status
        extraConfig.status.submoduleSummary = true;
      };
      programs.lazygit.enable = true;
      # Jujutsu (alternative DVCS (git-compatible))
      programs.jujutsu.enable = true;
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
