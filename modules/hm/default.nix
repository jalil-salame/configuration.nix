{
  config,
  pkgs,
  lib,
  fromOs,
  ...
}@attrs:
let
  cfg = config.jhome;
  devcfg = cfg.dev;
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
    (lib.mkIf (cfg.enable && cfg.styling.enable && !cfg.gui.enable) {
      # Stylix disable graphical targets when no GUI is requested
      stylix.targets = {
        gtk.enable = false;
        qt.enable = false;
        gnome.enable = false;
        kde.enable = false;
        xresources.enable = false;
      };
    })
    (lib.mkIf cfg.enable {
      # Add gopass if pass is enabled
      home.packages = lib.optional config.programs.password-store.enable pkgs.gopass;

      nix = {
        # Run GC for Home Manager generations
        gc = {
          automatic = true;
          frequency = "weekly";
          options = "--delete-older-than 30d";
          # run between 0 and 45min after boot if run was missed
          randomizedDelaySec = "45min";
        };

        # Use XDG directories
        settings.use-xdg-base-directories = fromOs [
          "nix"
          "settings"
          "use-xdg-base-directories"
        ] true;
      };

      programs = {
        # Switch to fish if bash is started interactively
        bash.initExtra = ''
          if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
        '';
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
          nix-direnv = {
            enable = true;
            package = pkgs.lixPackageSets.latest.nix-direnv;
          };
          stdlib = # bash
            ''
              : "''${XDG_CACHE_HOME:="''${HOME}/.cache"}"
              declare -A direnv_layout_dirs
              direnv_layout_dir() {
                  local hash path
                  echo "''${direnv_layout_dirs[$PWD]:=$(
                      hash="$(sha1sum - <<< "$PWD" | head -c40)"
                      path="''${PWD//[^a-zA-Z0-9]/-}"
                      echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
                  )}"
              }
            '';
        };
        # ls replacement
        eza = {
          enable = true;
          git = true;
          icons = "auto";
        };
        # Shell
        bash.enable = true; # ensure HM variables are passed to `bash` too (otherwise `jpassmenu` doesn't work)
        fish = {
          enable = true;
          preferAbbrs = true; # when defining an alias, prefer instead to define an abbreviation
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
      };

      services = {
        # GPG Agent
        gpg-agent = {
          enable = true;
          maxCacheTtl = 86400;
          pinentry.package = if config.jhome.gui.enable then pkgs.pinentry-qt else pkgs.pinentry-curses;
          extraConfig = "allow-preset-passphrase";
        };
        # Delete old generations (>month)
        home-manager.autoExpire.enable = true;
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
