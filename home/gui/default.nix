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
      (with pkgs; [
        webcord
        ferdium
        xournalpp
        signal-desktop
        lxqt.pcmanfm-qt
        wl-clipboard
        # Extra fonts
        noto-fonts-cjk-sans # Chinese, Japanese and Korean characters
        noto-fonts-cjk-serif # Chinese, Japanese and Korean characters
        (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      ])
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
        style =
          lib.optionalString config.jhome.styling.enable # css
            ''
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
      alacritty.enable = cfg.terminal == "alacritty";
      zellij.enable = cfg.terminal == "alacritty"; # alacritty has no terminal multiplexer built-in
      # PDF reader
      zathura.enable = true;
      # Auto start sway
      zsh.loginExtra =
        lib.optionalString cfg.sway.autostart # sh
          ''
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
    niri = {
      package = pkgs.niri; # use nixpkgs' package instead of the flake's
      settings = {
        binds =
          let
            # Modifier key
            mod = "Mod";
            # Available workspaces (1..=9)
            workspaces = lib.range 1 9;
            # Run function for each workspace
            perWorkspace = f: lib.mergeAttrsList (builtins.map f workspaces);
          in
          with config.lib.niri.actions;
          {
            # Open Terminal
            "${mod}+Return".action.spawn = config.jhome.gui.terminalCommand;
            # Open menu
            "${mod}+D".action =
              spawn "${lib.getExe pkgs.fuzzel}" "--terminal"
                "${builtins.concatStringSep " " terminalCommand}";
            # Close Window
            "${mod}+Q".action = close-window;
            # Fullscreen
            "${mod}+F".action = fullscreen-window;
            # Hotkey help menu
            "${mod}+Shift+/".action = show-hotkey-overlay;
            # Media Keys
            "XF86AudioRaiseVolume" = {
              action = spawn "${pkgs.avizo}/bin/volumectl" "up";
              allow-when-locked = true;
            };
            "XF86AudioLowerVolume" = {
              action = spawn "${pkgs.avizo}/bin/volumectl" "down";
              allow-when-locked = true;
            };
            "XF86AudioMute" = {
              action = spawn "${pkgs.avizo}/bin/volumectl" "toggle-mute";
              allow-when-locked = true;
            };
            # Lock screen
            "XF86ScreenSaver".action = spawn "swaylock" "--image" "${cfg.background}";
            # Screen brightness
            "XF86MonBrightnessUp".action = spawn "${pkgs.avizo}/bin/lightctl" "up";
            "XF86MonBrightnessDown".action = spawn "${pkgs.avizo}/bin/lightctl" "down";
          }
          // perWorkspace (workspace: {
            # Focus workspace N
            "${mod}+${builtins.toString workspace}".action = focus-workspace workspace;
          });
      };
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
