{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  inherit (config) jhome;
  flatpakEnabled = if osConfig != null then osConfig.services.flatpak.enable else false;
  osSway = osConfig == null && !osConfig.programs.sway.enable;
  swayPkg = if osSway then pkgs.sway else null;
  cfg = jhome.gui;
  cursor = {
    package = pkgs.nordzy-cursor-theme;
    size = 48;
    name = "Nordzy-cursors";
  };
in
{
  imports = [
    ./sway.nix
    ./waybar.nix
  ];

  config = lib.mkIf (jhome.enable && cfg.enable) {
    home.packages = [
      pkgs.webcord
      pkgs.ferdium
      pkgs.xournalpp
      pkgs.signal-desktop
      pkgs.pcmanfm
      pkgs.wl-clipboard
      # Extra fonts
      pkgs.noto-fonts-cjk-sans # Chinese, Japanese and Korean characters
      pkgs.noto-fonts-cjk-serif # Chinese, Japanese and Korean characters
      pkgs.nerd-fonts.symbols-only
    ]
    ++ lib.optional flatpakEnabled pkgs.flatpak;
    fonts.fontconfig = {
      enable = true;
      defaultFonts = lib.mkIf config.jhome.styling.enable {
        emoji = [ "Noto Color Emoji" ];
        monospace = [
          "JetBrains Mono"
          "Symbols Nerd Font"
        ];
        serif = [
          "Noto Serif"
          "Symbols Nerd Font"
        ];
        sansSerif = [
          "Noto Sans"
          "Symbols Nerd Font"
        ];
      };
    };
    # Browser
    programs = {
      firefox = {
        enable = true;
        profiles."${config.home.username}" = {
          search = {
            force = true; # firefox replaces the search settings, force replace them back
            engines =
              let
                queryParam = name: value: { inherit name value; };
              in
              {
                # Add search.nixos.org as search engines
                nix-packages = {
                  name = "Nix Packages";
                  urls = [
                    {
                      template = "https://search.nixos.org/packages";
                      params = [
                        (queryParam "type" "packages")
                        (queryParam "query" "{searchTerms}")
                      ];
                    }
                  ];

                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [
                    "@np"
                    "@nixpackages"
                  ];
                };

                nixos-options = {
                  name = "NixOS Options";
                  urls = [
                    {
                      template = "https://search.nixos.org/options";
                      params = [
                        (queryParam "type" "packages")
                        (queryParam "query" "{searchTerms}")
                      ];
                    }
                  ];

                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [
                    "@no"
                    "@nixopts"
                  ];
                };

                nixos-wiki = {
                  name = "NixOS Wiki";
                  urls = [
                    {
                      template = "https://wiki.nixos.org/w/index.php";
                      params = [ (queryParam "search" "{searchTerms}") ];
                    }
                  ];
                  iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
                  definedAliases = [
                    "@nw"
                    "@nixwiki"
                  ];
                };

                # hide bing
                bing.metaData.hidden = true;
              };
          };
        };
      };
      # Dynamic Menu
      fuzzel = {
        enable = true;
        settings.main = lib.mkIf config.jhome.styling.enable {
          inherit (cfg) terminal;
          layer = "overlay";
        };
      };
      # Video player
      mpv = {
        enable = true;
        scripts = builtins.attrValues { inherit (pkgs.mpvScripts) uosc thumbfast; };
      };
      # Text editor
      nixvim.clipboard.providers.wl-copy.enable = lib.mkDefault true;
      # Terminal
      wezterm = {
        enable = cfg.terminal == "wezterm";
        extraConfig =
          lib.optionalString config.jhome.styling.enable # lua
            ''
              local wezterm = require("wezterm")

              local config = wezterm.config_builder()

              config.front_end = "WebGpu"
              config.hide_tab_bar_if_only_one_tab = true
              config.window_padding = { left = 1, right = 1, top = 1, bottom = 1 }

              return config
            '';
      };
      alacritty = {
        enable = cfg.terminal == "alacritty";
        settings = {
          # hide mouse when typing, this ensures I don't have to move the mouse when it hides text
          mouse.hide_when_typing = true;
          # Start zellij when it is enabled
          terminal.shell = lib.mkIf (config.jhome.dev.enable && config.programs.zellij.enable) {
            program = "${lib.getExe config.programs.zellij.package}";
          };
        };
      };
      # alacritty has no terminal multiplexer built-in use zellij
      zellij.enable = cfg.terminal == "alacritty";
      # PDF reader
      zathura.enable = true;
      # Auto start sway
      fish.loginShellInit =
        lib.optionalString cfg.sway.autostart # fish
          ''
            # Start Sway on login to TTY 1
            if test "$(tty)" = /dev/tty1
              exec sway
            end
          '';
    };
    services = {
      # Volume/Backlight control and notifications
      avizo = {
        enable = true;
        settings.default = {
          time = 0.8;
          border-width = 0;
          height = 176;
          y-offset = 0.1;
          block-spacing = 1;
        };
      };
      # Sound tuning
      easyeffects.enable = true;
      # Auto configure displays
      kanshi.enable = lib.mkDefault true;
      # Notifications
      mako = {
        enable = true;
        settings = {
          layer = "overlay";
          border-radius = 8;
          default-timeout = 15000;
        };
      };
    };

    stylix = lib.mkIf config.jhome.styling.enable {
      # Set cursor style
      inherit cursor;
      targets.firefox.profileNames = [ config.home.username ];
      iconTheme = {
        enable = true;
        light = "Papirus-Light";
        dark = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };
    home.pointerCursor = lib.mkIf config.jhome.styling.enable (
      lib.mkDefault {
        gtk.enable = true;
        inherit (cursor) name package;
      }
    );
    # Set Gtk theme
    gtk = lib.mkIf config.jhome.styling.enable {
      enable = true;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    };
    # Set Qt theme
    qt = lib.mkIf config.jhome.styling.enable { enable = true; };

    xdg.systemDirs.data = [
      "/usr/share"
      "/var/lib/flatpak/exports/share"
      "${config.xdg.dataHome}/flatpak/exports/share"
    ];
  };
}
