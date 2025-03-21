{
  config,
  pkgs,
  lib,
  osConfig ? null,
  ...
}:
let
  cfg = config.jhome;
  devcfg = cfg.dev;
  # Query the osConfig for a setting. Return the default value if missing or in standalone mode
  fromOs =
    path: default: if osConfig == null then default else lib.attrsets.attrByPath path default osConfig;
in
{
  imports = [
    ./options.nix
    ./gui
    ./dev.nix
    ./users.nix
  ];

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.styling.enable) {
      stylix = {
        enable = true;
        targets.nixvim.enable = false; # I prefer styling it myself
      };
    })
    (lib.mkIf cfg.enable {
      # Add gopass if pass is enabled
      home.packages = lib.optional config.programs.password-store.enable pkgs.gopass;

      nix.settings.use-xdg-base-directories = fromOs [
        "nix"
        "settings"
        "use-xdg-base-directories"
      ] true;

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
          icons = "auto";
        };
        # GnuPG
        gpg = {
          enable = true;
          homedir = "${config.xdg.dataHome}/gnupg";
        };
        # Mail client
        himalaya.enable = lib.mkDefault true;
        # Password manager
        password-store = {
          enable = lib.mkDefault true;
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
  ];
}
