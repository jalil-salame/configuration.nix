{ config, lib }:
let cfg = config.jhome.gui; in
{
  mainBar.layer = "top";
  mainBar.position = "top";
  mainBar.margin = "2 2 2 2";
  # Choose the order of the modules
  mainBar.modules-left = [ "sway/workspaces" ];
  mainBar.modules-center = [ "clock" ];
  mainBar.modules-right = [ "pulseaudio" "backlight" "battery" "sway/language" "memory" ]
    ++ lib.optional (cfg.tempInfo != null) "temperature"
    ++ [ "tray" ];
  mainBar."sway/workspaces".disable-scroll = true;
  mainBar."sway/workspaces".persistent_workspaces."1" = [ ];
  mainBar."sway/workspaces".persistent_workspaces."2" = [ ];
  mainBar."sway/workspaces".persistent_workspaces."3" = [ ];
  mainBar."sway/workspaces".persistent_workspaces."4" = [ ];
  mainBar."sway/workspaces".persistent_workspaces."5" = [ ];
  mainBar."sway/workspaces".persistent_workspaces."6" = [ ];
  mainBar."sway/workspaces".persistent_workspaces."7" = [ ];
  mainBar."sway/workspaces".persistent_workspaces."8" = [ ];
  mainBar."sway/workspaces".persistent_workspaces."9" = [ ];
  mainBar."sway/language".format = "{} ";
  mainBar."sway/language".min-length = 5;
  mainBar."sway/language".tooltip = false;
  mainBar.memory.format = "{used:0.1f}/{total:0.1f}GiB ";
  mainBar.memory.interval = 3;
  mainBar.clock.timezone = "Europe/Berlin";
  mainBar.clock.tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
  mainBar.clock.format = "{:%a, %d %b, %H:%M}";
  mainBar.pulseaudio.reverse-scrolling = 1;
  mainBar.pulseaudio.format = "{volume}% {icon} {format_source}";
  mainBar.pulseaudio.format-bluetooth = "{volume}% {icon} {format_source}";
  mainBar.pulseaudio.format-bluetooth-muted = "{volume}% 󰖁 {icon} {format_source}";
  mainBar.pulseaudio.format-muted = "{volume}% 󰖁 {format_source}";
  mainBar.pulseaudio.format-source = "{volume}% ";
  mainBar.pulseaudio.format-source-muted = "{volume}% 󰍭";
  mainBar.pulseaudio.format-icons.headphone = "󰋋";
  mainBar.pulseaudio.format-icons.hands-free = "";
  mainBar.pulseaudio.format-icons.headset = "󰋎";
  mainBar.pulseaudio.format-icons.phone = "󰘂";
  mainBar.pulseaudio.format-icons.portable = "";
  mainBar.pulseaudio.format-icons.car = "";
  mainBar.pulseaudio.format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
  mainBar.pulseaudio.on-click = "pavucontrol";
  mainBar.pulseaudio.min-length = 13;
  mainBar.temperature =
    lib.optionalAttrs (cfg.tempInfo != null) {
      inherit (cfg.tempInfo) hwmon-path;
      critical-threshold = 80;
      format = "{temperatureC}°C {icon}";
      format-icons = [ "" "" "" "" "" ];
      tooltip = false;
    };
  mainBar.backlight.device = "intel_backlight";
  mainBar.backlight.format = "{percent}% {icon}";
  mainBar.backlight.format-icons = [ "󰃚" "󰃛" "󰃜" "󰃝" "󰃞" "󰃟" "󰃠" ];
  mainBar.backlight.min-length = 7;
  mainBar.battery.states.warning = 30;
  mainBar.battery.states.critical = 15;
  mainBar.battery.format = "{capacity}% {icon}";
  mainBar.battery.format-charging = "{capacity}% 󰂄";
  mainBar.battery.format-plugged = "{capacity}% 󰚥";
  mainBar.battery.format-alt = "{time} {icon}";
  mainBar.battery.format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
  mainBar.tray.icon-size = 16;
  mainBar.tray.spacing = 0;
}
