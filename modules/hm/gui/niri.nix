{
  config,
  pkgs,
  lib,
  fromOs,
  ...
}:
let
  cfgGui = config.jhome.gui;
  cfg = cfgGui.niri;
  enable = config.jhome.enable && cfgGui.enable && cfg.enable;

  volumectl = "${pkgs.avizo}/bin/volumectl";
  lightctl = "${pkgs.avizo}/bin/lightctl";

  inherit (cfgGui) terminal;
  termCmd =
    if terminal == "wezterm" then
      [
        "wezterm"
        "start"
      ]
    else if terminal == "alacritty" then
      [
        "alacritty"
        "-e"
      ]
    else
      builtins.abort "no command configured for ${terminal}";
  menu = [
    "${pkgs.fuzzel}/bin/fuzzel"
    "--terminal"
    (lib.escapeShellArgs termCmd)
  ]
  ++ termCmd;
  passmenu = "${pkgs.jpassmenu}/bin/jpassmenu";
  audiomenu = "${pkgs.audiomenu}/bin/audiomenu";
in
{
  config.programs.niri = {
    inherit enable;
    package = fromOs [ "programs" "niri" "package" ] pkgs.niri;

    settings = {
      binds = with config.lib.niri.actions; {
        # Niri native
        "Mod+O" = {
          action = toggle-overview;
          repeat = false;
        };
        "Mod+Shift+Slash".action = show-hotkey-overlay;
        "Mod+O" = {
          action = toggle-overview;
          repeat = false;
        };

        # Audio
        "XF86AudioRaiseVolume" = {
          action = spawn volumectl "up";
          allow-when-locked = true;
        };
        "XF86AudioLowerVolume" = {
          action = spawn volumectl "down";
          allow-when-locked = true;
        };
        "XF86AudioMute" = {
          action = spawn volumectl "toggle-mute";
          allow-when-locked = true;
        };
        # Brightness
        "XF86MonBrightnessUp" = {
          action = spawn lightctl "up";
          allow-when-locked = true;
        };
        "XF86MonBrightnessDown" = {
          action = spawn lightctl "down";
          allow-when-locked = true;
        };
        # Screen Lock
        "XF86ScreenSaver" = {
          action = spawn "${pkgs.swaylock}/bin/swaylock" "--image" "${cfgGui.wallpaper}";
          hotkey-overlay-title = "Lock the Screen: swaylock";
        };

        # App shortcuts
        "Mod+Return" = {
          action.spawn = termCmd;
          hotkey-overlay-title = "Open a Terminal: ${terminal}";
        };
        "Mod+D" = {
          action.spawn = menu;
          hotkey-overlay-title = "Run an Application: fuzzel";
        };
        "Mod+F2".action = spawn "firefox";
        "Mod+P".action = spawn passmenu;
        "Mod+Shift+P".action = spawn passmenu "--type";
        "Mod+F10".action = spawn audiomenu "select-sink";
        "Mod+Shift+F10".action = spawn audiomenu "select-source";

        # Window controls
        ## Window Size
        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-window-height;
        "Mod+Ctrl+R".action = reset-window-height;
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+Ctrl+F".action = expand-column-to-available-width;
        "Mod+C".action = center-column;
        "Mod+Ctrl+C".action = center-visible-columns;
        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";
        "Mod+Shift+Minus".action = set-window-height "-10%";
        "Mod+Shift+Equal".action = set-window-height "+10%";
        ## Window actions
        "Mod+Shift+Q" = {
          action = close-window;
          repeat = false;
        };
        ## Move into/out of a column
        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;
        "Mod+Comma".action = consume-window-into-column;
        "Mod+Period".action = expel-window-from-column;
        ## Focus with arrow/vim keys
        "Mod+Left".action = focus-column-left;
        "Mod+Down".action = focus-window-down;
        "Mod+Up".action = focus-window-up;
        "Mod+Right".action = focus-column-right;
        "Mod+H".action = focus-column-left;
        "Mod+J".action = focus-window-down;
        "Mod+K".action = focus-window-up;
        "Mod+L".action = focus-column-right;
        ## Move with arrow/vim keys
        "Mod+Ctrl+Left".action = move-column-left;
        "Mod+Ctrl+Down".action = move-window-down;
        "Mod+Ctrl+Up".action = move-window-up;
        "Mod+Ctrl+Right".action = move-column-right;
        "Mod+Ctrl+H".action = move-column-left;
        "Mod+Ctrl+J".action = move-window-down;
        "Mod+Ctrl+K".action = move-window-up;
        "Mod+Ctrl+L".action = move-column-right;
        ## Focus/Move first/last
        "Mod+Home".action = focus-column-first;
        "Mod+End".action = focus-column-last;
        "Mod+Ctrl+Home".action = move-column-to-first;
        "Mod+Ctrl+End".action = move-column-to-last;
        ## Focus monitor
        "Mod+Shift+Left".action = focus-monitor-left;
        "Mod+Shift+Down".action = focus-monitor-down;
        "Mod+Shift+Up".action = focus-monitor-up;
        "Mod+Shift+Right".action = focus-monitor-right;
        "Mod+Shift+H".action = focus-monitor-left;
        "Mod+Shift+J".action = focus-monitor-down;
        "Mod+Shift+K".action = focus-monitor-up;
        "Mod+Shift+L".action = focus-monitor-right;
        ## Move column to monitor
        "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
        "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;
        ## Move/focus workspace
        "Mod+Page_Down".action = focus-workspace-down;
        "Mod+Page_Up".action = focus-workspace-up;
        "Mod+U".action = focus-workspace-down;
        "Mod+I".action = focus-workspace-up;
        "Mod+Shift+Page_Down".action = move-workspace-down;
        "Mod+Shift+Page_Up".action = move-workspace-up;
        "Mod+Shift+U".action = move-workspace-down;
        "Mod+Shift+I".action = move-workspace-up;
        ## Move column to workspace
        "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
        "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
        "Mod+Ctrl+U".action = move-column-to-workspace-down;
        "Mod+Ctrl+I".action = move-column-to-workspace-up;

        ## Numbered workspaces
        ### Focus numbered
        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;
        ### Move to numbered
        "Mod+Ctrl+1".action = move-column-to-workspace 1;
        "Mod+Ctrl+2".action = move-column-to-workspace 2;
        "Mod+Ctrl+3".action = move-column-to-workspace 3;
        "Mod+Ctrl+4".action = move-column-to-workspace 4;
        "Mod+Ctrl+5".action = move-column-to-workspace 5;
        "Mod+Ctrl+6".action = move-column-to-workspace 6;
        "Mod+Ctrl+7".action = move-column-to-workspace 7;
        "Mod+Ctrl+8".action = move-column-to-workspace 8;
        "Mod+Ctrl+9".action = move-column-to-workspace 9;

        # Screenshot
        "Print".action = screenshot;
        "Ctrl+Print".action = screenshot-screen;
        "Alt+Print".action = screenshot-window;
        # Floating
        "Mod+Space".action = toggle-window-floating;
        "Mod+Shift+Space".action = switch-focus-between-floating-and-tiling;
        # Layout
        "Mod+e".action = switch-layout "next";
        "Mod+Shift+e".action = switch-layout "prev";
        # Session
        "Mod+m".action = quit { skip-confirmation = false; };
        "Mod+Shift+m".action = quit { skip-confirmation = true; };
      };
    };
  };
}
