{ config, pkgs }:
let
  cfg = config.jhome.gui.sway;
  modifier = "Mod4";
  terminal = "wezterm";
  menu = "${pkgs.fuzzel}/bin/fuzzel --terminal 'wezterm start'";
  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk =
    let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in
    pkgs.writers.writeDashBin "configure-gtk"
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        config="${config.xdg.configHome}/gtk-3.0/settings.ini"
        if [ ! -f "$config" ]; then exit 1; fi
        # Read settings from gtk3
        gtk_theme="$(${pkgs.gnugrep}/bin/grep 'gtk-theme-name' "$config" | ${pkgs.gnused}/bin/sed 's/.*\s*=\s*//')"
        icon_theme="$(${pkgs.gnugrep}/bin/grep 'gtk-icon-theme-name' "$config" | ${pkgs.gnused}/bin/sed 's/.*\s*=\s*//')"
        cursor_theme="$(${pkgs.gnugrep}/bin/grep 'gtk-cursor-theme-name' "$config" | ${pkgs.gnused}/bin/sed 's/.*\s*=\s*//')"
        font_name="$(grep 'gtk-font-name' "$config" | sed 's/.*\s*=\s*//')"
        ${pkgs.glib}/bin/gsettings set "$gnome_schema" gtk-theme "$gtk_theme"
        ${pkgs.glib}/bin/gsettings set "$gnome_schema" icon-theme "$icon_theme"
        ${pkgs.glib}/bin/gsettings set "$gnome_schema" cursor-theme "$cursor_theme"
        ${pkgs.glib}/bin/gsettings set "$gnome_schema" font-name "$font_name"
        ${pkgs.glib}/bin/gsettings set "$gnome_schema" color-scheme prefer-dark
      '';
  cmdOnce = command: { inherit command; };
  cmdAlways = command: {
    inherit command;
    always = true;
  };
in
{
  inherit modifier terminal menu;
  keybindings = import ./keybindings.nix { inherit config pkgs; };
  # Appearance
  bars = [ ]; # Waybar is started as a systemd service
  gaps = {
    smartGaps = true;
    smartBorders = "on";
    inner = 4;
  };
  output."*".bg = "${cfg.background} fill";
  # Window Appearance
  window.border = 2;
  # Make certain windows floating
  window.commands = [
    { command = "floating enable"; criteria.title = "zoom"; }
    { command = "floating enable"; criteria.class = "floating"; }
    { command = "floating enable"; criteria.app_id = "floating"; }
  ];
  # Startup scripts
  startup =
    [ (cmdAlways "${configure-gtk}/bin/configure-gtk") ]
    ++ (builtins.map cmdAlways cfg.exec.always)
    ++ (builtins.map cmdOnce cfg.exec.once);
  # Keyboard configuration
  input."type:keyboard".repeat_delay = "300";
  input."type:keyboard".repeat_rate = "50";
  input."type:keyboard".xkb_options = "caps:swapescape";
  input."type:keyboard".xkb_numlock = "enabled";
  # Touchpad
  input."type:touchpad".click_method = "clickfinger";
  input."type:touchpad".natural_scroll = "enabled";
  input."type:touchpad".scroll_method = "two_finger";
  input."type:touchpad".tap = "enabled";
  input."type:touchpad".tap_button_map = "lrm";
}
