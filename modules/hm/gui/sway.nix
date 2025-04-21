{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.jhome.gui.sway;
in
{
  config = lib.mkIf (config.jhome.enable && config.jhome.gui.enable && cfg.enable) {
    # Window Manager
    wayland.windowManager.sway = {
      inherit (cfg) enable;
      config =
        let
          inherit (config.jhome.gui) terminal;
          termCmd =
            if terminal == "wezterm" then
              "wezterm start"
            else if terminal == "alacritty" then
              "alacritty -e"
            else
              builtins.abort "no command configured for ${terminal}";
          menu = "${pkgs.fuzzel}/bin/fuzzel --terminal '${termCmd}'";
          cmdOnce = command: { inherit command; };
          cmdAlways = command: {
            inherit command;
            always = true;
          };
        in
        {
          modifier = "Mod4";
          inherit terminal menu;
          # Appearance
          bars = [ ]; # Waybar is started as a systemd service
          gaps = {
            smartGaps = true;
            smartBorders = "on";
            inner = 4;
          };
          output."*".bg = "${cfg.background} fill";
          # Window Appearance
          window = {
            border = 2;
            titlebar = false;
            # Make certain windows floating
            commands = [
              {
                command = "floating enable";
                criteria.title = "zoom";
              }
              {
                command = "floating enable";
                criteria.class = "floating";
              }
              {
                command = "floating enable";
                criteria.app_id = "floating";
              }
            ];
          };
          # Startup scripts
          startup =
            let
              # currently, there is some friction between sway and gtk:
              # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
              # the suggested way to set gtk settings is with gsettings
              # for gsettings to work, we need to tell it where the schemas are
              # using the XDG_DATA_DIR environment variable
              # run at the end of sway config
              schema = pkgs.gsettings-desktop-schemas;
              datadir = "${schema}/share/gsettings-schemas/${schema.name}";
            in
            [
              (cmdAlways "${pkgs.writers.writeDash "configure-gtk" ''
                export XDG_DATA_DIRS="${datadir}:$XDG_DATA_DIRS"

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
              ''}")
            ]
            ++ (builtins.map cmdAlways cfg.exec.always)
            ++ (builtins.map cmdOnce cfg.exec.once);
          # Keyboard configuration
          input."type:keyboard" = {
            repeat_delay = "300";
            repeat_rate = "50";
            xkb_options = "caps:swapescape,compose:ralt";
            xkb_numlock = "enabled";
          };
          # Touchpad
          input."type:touchpad" = {
            click_method = "clickfinger";
            natural_scroll = "enabled";
            scroll_method = "two_finger";
            tap = "enabled";
            tap_button_map = "lrm";
          };
          # Keybinds
          keybindings =
            let
              passmenu = "${pkgs.jpassmenu}/bin/jpassmenu";
              selectAudio = "${pkgs.audiomenu}/bin/audiomenu";
              swayconf = config.wayland.windowManager.sway.config;
              mod = swayconf.modifier;
              workspaces = map toString (lib.lists.range 1 9);
              dirs =
                map
                  (dir: {
                    key = swayconf.${dir};
                    arrow = dir;
                    direction = dir;
                  })
                  [
                    "up"
                    "down"
                    "left"
                    "right"
                  ];
              joinKeys = builtins.concatStringsSep "+";
              # Generate a keybind from a modifier prefix and a key
              keycombo = prefix: key: joinKeys (prefix ++ [ key ]);
              modKeybind = keycombo [ mod ];
              modCtrlKeybind = keycombo [
                mod
                "Ctrl"
              ];
              modShiftKeybind = keycombo [
                mod
                "Shift"
              ];
              modCtrlShiftKeybind = keycombo [
                mod
                "Ctrl"
                "Shift"
              ];
              dir2resize.up = "resize grow height";
              dir2resize.down = "resize shrink height";
              dir2resize.right = "resize grow width";
              dir2resize.left = "resize shrink width";
              # Bind a key combo to an action
              genKeybind = prefix: action: key: { "${prefix key}" = "${action key}"; };
              genKey =
                prefix: action: genKeybind ({ key, ... }: prefix key) ({ direction, ... }: action direction);
              genArrow =
                prefix: action: genKeybind ({ arrow, ... }: prefix arrow) ({ direction, ... }: action direction);
              genArrowAndKey =
                prefix: action: key:
                (genKey prefix action key) // (genArrow prefix action key);
              # Move window
              moveWindowKeybinds = map (genArrowAndKey modShiftKeybind (dir: "move ${dir}")) dirs;
              # Focus window
              focusWindowKeybinds = map (genArrowAndKey modKeybind (dir: "focus ${dir}")) dirs;
              # Resize window
              resizeWindowKeybinds = map (genArrowAndKey modCtrlKeybind (dir: dir2resize.${dir})) dirs;
              # Move container to workspace
              moveWorkspaceKeybindings = map (genKeybind modShiftKeybind (
                number: "move container to workspace number ${number}"
              )) workspaces;
              # Focus workspace
              focusWorkspaceKeybindings = map (genKeybind modKeybind (
                number: "workspace number ${number}"
              )) workspaces;
              # Move container to Workspace and focus on it
              moveFocusWorkspaceKeybindings = map (genKeybind modCtrlShiftKeybind (
                number: "move container to workspace number ${number}; workspace number ${number}"
              )) workspaces;
            in
            builtins.foldl' (l: r: l // r)
              {
                "${mod}+Return" = "exec ${swayconf.terminal}";
                "${mod}+D" = "exec ${swayconf.menu}";
                "${mod}+P" = "exec ${passmenu}";
                "${mod}+Shift+P" = "exec ${passmenu} --type";
                "${mod}+F2" = "exec qutebrowser";
                "${mod}+Shift+Q" = "kill";
                "${mod}+F" = "fullscreen toggle";
                # Media Controls
                "${mod}+F10" = "exec ${selectAudio} select-sink";
                "${mod}+Shift+F10" = "exec ${selectAudio} select-source";
                "XF86AudioRaiseVolume" = "exec ${pkgs.avizo}/bin/volumectl up";
                "XF86AudioLowerVolume" = "exec ${pkgs.avizo}/bin/volumectl down";
                "XF86AudioMute" = "exec ${pkgs.avizo}/bin/volumectl toggle-mute";
                "XF86ScreenSaver" = "exec ${pkgs.swaylock}/bin/swaylock --image ${cfg.background}";
                "XF86MonBrightnessUp" = "exec ${pkgs.avizo}/bin/lightctl up";
                "XF86MonBrightnessDown" = "exec ${pkgs.avizo}/bin/lightctl down";
                # Floating
                "${mod}+Space" = "floating toggle";
                "${mod}+Shift+Space" = "focus mode_toggle";
                # Scratchpad
                "${mod}+Minus" = "scratchpad show";
                "${mod}+Shift+Minus" = "move scratchpad";
                # Layout
                "${mod}+e" = "layout toggle split";
                # Session control
                "${mod}+r" = "reload";
                "${mod}+Shift+m" = "exit";
              }
              (
                focusWindowKeybinds
                ++ moveWindowKeybinds
                ++ resizeWindowKeybinds
                ++ focusWorkspaceKeybindings
                ++ moveWorkspaceKeybindings
                ++ moveFocusWorkspaceKeybindings
              );
        };
      systemd = {
        enable = true;
        xdgAutostart = true;
      };
    };
  };
}
