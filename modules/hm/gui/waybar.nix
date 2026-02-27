{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config) jhome;
  cfg = jhome.gui;
  swayconf = config.wayland.windowManager.sway;
in
{
  config = lib.mkIf (config.jhome.enable && cfg.enable) {
    # Status bar
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = lib.mkIf config.jhome.styling.enable {
        mainBar = {
          layer = "top";
          position = "top";
          margin = "2 2 2 2";
          # Choose the order of the modules
          modules-left = [ "sway/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [
            "pulseaudio"
            "backlight"
            "battery"
            "sway/language"
            "memory"
          ]
          ++ lib.optional (cfg.tempInfo != null) "temperature"
          ++ [ "tray" ];
          "sway/workspaces" = lib.mkIf swayconf.enable {
            disable-scroll = true;
            persistent-workspaces = {
              "1" = [ ];
              "2" = [ ];
              "3" = [ ];
              "4" = [ ];
              "5" = [ ];
              "6" = [ ];
              "7" = [ ];
              "8" = [ ];
              "9" = [ ];
            };
          };
          "sway/language" = lib.mkIf swayconf.enable {
            format = "{} ";
            min-length = 5;
            tooltip = false;
          };
          memory = {
            format = "{used:0.1f}/{total:0.1f}GiB ";
            interval = 3;
          };
          clock = {
            timezone = "Europe/Berlin";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format = "{:%a, %d %b, %H:%M}";
          };
          pulseaudio = {
            reverse-scrolling = 1;
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = "{volume}% 󰖁 {icon} {format_source}";
            format-muted = "{volume}% 󰖁 {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "{volume}% 󰍭";
            format-icons = {
              headphone = "󰋋";
              hands-free = "";
              headset = "󰋎";
              phone = "󰘂";
              portable = "";
              car = "";
              default = [
                "󰕿"
                "󰖀"
                "󰕾"
              ];
            };
            on-click = lib.getExe pkgs.helvum;
            min-length = 13;
          };
          temperature = lib.optionalAttrs (cfg.tempInfo != null) {
            inherit (cfg.tempInfo) hwmon-path;
            critical-threshold = 80;
            format = "{temperatureC}°C {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
            tooltip = false;
          };
          backlight = {
            device = "intel_backlight";
            format = "{percent}% {icon}";
            format-icons = [
              "󰃚"
              "󰃛"
              "󰃜"
              "󰃝"
              "󰃞"
              "󰃟"
              "󰃠"
            ];
            min-length = 7;
          };
          battery = {
            states.warning = 30;
            states.critical = 15;
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% 󰂄";
            format-plugged = "{capacity}% 󰚥";
            format-alt = "{time} {icon}";
            format-icons = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
          };
          tray = {
            icon-size = 16;
            spacing = 0;
          };
        };
      };
      style =
        # css
        ''
          * {
            border: none;
            border-radius: 0;
            font-size: 13px;
            min-height: 0;
            min-width: 0px;
          }

          window#waybar {
              background-color: @base;
              border-bottom: 3px solid @mantle;
              color: @text;
              transition-property: background-color;
              transition-duration: .5s;
          }

          window#waybar.hidden {
              opacity: 0.2;
          }

          #window, #workspaces {
              margin: 0 4px;
          }

          #clock,
          #battery,
          #cpu,
          #memory,
          #disk,
          #temperature,
          #backlight,
          #network,
          #pulseaudio,
          #wireplumber,
          #custom-media,
          #tray,
          #mode,
          #idle_inhibitor,
          #scratchpad,
          #power-profiles-daemon,
          #mpd {
              padding: 0 3px;
              color: @text;
          }

          #workspaces button {
            border-bottom: 3px solid @surface0;
          }

          #workspaces button.visible {
            border-bottom: 3px solid @surface2;
          }

          #workspaces button.focused {
            border-bottom: 3px solid @mauve;
          }

          #workspaces button.persistent {
            border-bottom: 3px solid transparent;
          }

          #workspaces button.urgent {
              background-color: @red;
          }

          /* If workspaces is the leftmost module, omit left margin */
          .modules-left > widget:first-child > #workspaces {
              margin-left: 0;
          }

          #tray {
              background-color: @base;
          }

          #tray > .passive {
              -gtk-icon-effect: dim;
          }

          #tray > .needs-attention {
              -gtk-icon-effect: highlight;
              background-color: @red;
          }
        '';
    };
  };
}
