{ config, lib, pkgs, osConfig ? null, ... }:
let
  inherit (config) jhome;
  flatpakEnabled = if osConfig != null then osConfig.services.flatpak.enable else false;
  osSway = osConfig == null && !osConfig.programs.sway.enable;
  swayPkg = if osSway then pkgs.sway else null;
  cfg = jhome.gui;
  cursor.package = pkgs.nordzy-cursor-theme;
  cursor.name = "Nordzy-cursors";
  iconTheme.name = "Papirus-Dark";
  iconTheme.package = pkgs.papirus-icon-theme;
in
{
  config = lib.mkIf (jhome.enable && cfg.enable) {
    home.packages = [
      pkgs.webcord
      pkgs.ferdium
      pkgs.xournalpp
      pkgs.signal-desktop
      pkgs.lxqt.pcmanfm-qt
      pkgs.wl-clipboard
      # Extra fonts
      pkgs.noto-fonts-cjk # Chinese, Japanese and Korean characters
    ] ++ lib.optional flatpakEnabled pkgs.flatpak;

    fonts.fontconfig.enable = true;

    # Browser
    programs.firefox.enable = true;
    # Dynamic Menu
    programs.fuzzel.enable = true;
    programs.fuzzel.settings.main.icon-theme = "Papirus-Dark";
    programs.fuzzel.settings.main.terminal = cfg.terminal;
    programs.fuzzel.settings.main.layer = "overlay";
    # Video player
    programs.mpv.enable = true;
    programs.mpv.scripts = builtins.attrValues { inherit (pkgs.mpvScripts) uosc thumbfast; };
    # Status bar
    programs.waybar.enable = true;
    programs.waybar.systemd.enable = true;
    programs.waybar.settings = import ./waybar-settings.nix { inherit config lib; };
    # Terminal
    programs.wezterm.enable = cfg.terminal == "wezterm";
    programs.wezterm.extraConfig = ''
      config = {}
      config.hide_tab_bar_if_only_one_tab = true
      config.window_padding = { left = 1, right = 1, top = 1, bottom = 1 }
      return config
    '';
    programs.alacritty.enable = cfg.terminal == "alacritty";
    programs.zellij.enable = cfg.terminal == "alacritty"; # alacritty has no terminal multiplexerr built in
    # PDF reader
    programs.zathura.enable = true;
    # Auto start sway
    programs.zsh.loginExtra = lib.optionalString cfg.sway.autostart ''
      # Start Sway on login to TTY 1
      if [ "$TTY" = /dev/tty1 ]; then
        exec sway
      fi
    '';

    # Volume/Backlight control and notifications
    services.avizo.enable = true;
    # Auto configure displays
    services.kanshi.enable = lib.mkDefault true;
    # Notifications
    services.mako.enable = true;
    services.mako.layer = "overlay";
    services.mako.borderRadius = 8;
    services.mako.defaultTimeout = 15000;

    # Window Manager
    wayland.windowManager.sway.enable = true;
    wayland.windowManager.sway.package = swayPkg; # no sway package if it comes from the OS
    wayland.windowManager.sway.config = import ./sway-config.nix { inherit config pkgs; };

    # Set cursor style
    stylix.cursor = cursor;
    home.pointerCursor.gtk.enable = true;

    # Set Gtk theme
    gtk.enable = true;
    gtk.iconTheme = iconTheme;
    gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk.gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    # Set Qt theme
    qt.enable = true;
    qt.platformTheme = "gtk";

    xdg.systemDirs.data = [
      "/usr/share"
      "/var/lib/flatpak/exports/share"
      "${config.xdg.dataHome}/flatpak/exports/share"
    ];
  };
}
