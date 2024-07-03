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
    name = "Nordzy-cursors";
  };
  iconTheme = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };
in
{
  config = lib.mkIf (jhome.enable && cfg.enable) {
    home.packages =
      with pkgs;
      [
        webcord
        ferdium
        xournalpp
        signal-desktop
        lxqt.pcmanfm-qt
        wl-clipboard
        # Extra fonts
        noto-fonts-cjk # Chinese, Japanese and Korean characters
        (pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      ]
      ++ lib.optional flatpakEnabled flatpak;
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
      firefox.enable = true;
      # Dynamic Menu
      fuzzel = {
        enable = true;
        settings.main = lib.mkIf config.jhome.styling.enable {
          icon-theme = "Papirus-Dark";
          inherit (cfg) terminal;
          layer = "overlay";
        };
      };
      # Video player
      mpv = {
        enable = true;
        scripts = builtins.attrValues { inherit (pkgs.mpvScripts) uosc thumbfast; };
      };
      # Status bar
      waybar = {
        enable = true;
        systemd.enable = true;
        settings = lib.mkIf config.jhome.styling.enable (
          import ./waybar-settings.nix { inherit config lib; }
        );
        style = lib.optionalString config.jhome.styling.enable ''
          .modules-left #workspaces button {
            border-bottom: 3px solid @base01;
          }
          .modules-left #workspaces button.persistent {
            border-bottom: 3px solid transparent;
          }
        '';
      };
      # Terminal
      wezterm = {
        enable = cfg.terminal == "wezterm";
        extraConfig = lib.optionalString config.jhome.styling.enable ''
          config = {}
          config.hide_tab_bar_if_only_one_tab = true
          config.window_padding = { left = 1, right = 1, top = 1, bottom = 1 }
          return config
        '';
      };
      alacritty.enable = cfg.terminal == "alacritty";
      zellij.enable = cfg.terminal == "alacritty"; # alacritty has no terminal multiplexer built-in
      # PDF reader
      zathura.enable = true;
      # Auto start sway
      zsh.loginExtra = lib.optionalString cfg.sway.autostart ''
        # Start Sway on login to TTY 1
        if [ "$TTY" = /dev/tty1 ]; then
          exec sway
        fi
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
        layer = "overlay";
        borderRadius = 8;
        defaultTimeout = 15000;
      };
    };

    # Window Manager
    wayland.windowManager.sway = {
      inherit (cfg.sway) enable;
      package = swayPkg; # no sway package if it comes from the OS
      config = import ./sway-config.nix { inherit config pkgs; };
    };

    # Set cursor style
    stylix = lib.mkIf config.jhome.styling.enable { inherit cursor; };
    home.pointerCursor = lib.mkIf config.jhome.styling.enable (
      lib.mkDefault {
        gtk.enable = true;
        inherit (cursor) name package;
      }
    );
    # Set Gtk theme
    gtk = lib.mkIf config.jhome.styling.enable {
      enable = true;
      inherit iconTheme;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    };
    # Set Qt theme
    qt = lib.mkIf config.jhome.styling.enable {
      enable = true;
      platformTheme.name = "gtk";
    };

    xdg.systemDirs.data = [
      "/usr/share"
      "/var/lib/flatpak/exports/share"
      "${config.xdg.dataHome}/flatpak/exports/share"
    ];
  };
}
