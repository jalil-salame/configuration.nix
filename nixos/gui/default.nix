{ config, lib, pkgs, ... }:
let
  cfg = config.jconfig.gui;
in
{
  config = lib.mkMerge [
    (lib.mkIf (config.jconfig.enable && cfg.enable) {
      environment.systemPackages = [
        pkgs.gnome.adwaita-icon-theme
        pkgs.adwaita-qt
        pkgs.nordzy-cursor-theme
        pkgs.pinentry-qt
      ] ++ lib.optional cfg.ydotool.enable pkgs.ydotool;

      systemd.user.services.ydotool = lib.mkIf cfg.ydotool.enable {
        enable = cfg.ydotool.autoStart;
        wantedBy = [ "default.target" ];
        description = "Generic command-line automation tool";
        documentation = [ "man:ydotool(1)" "man:ydotoold(8)" ];
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          ExecStart = "${pkgs.ydotool}/bin/ydotoold";
          ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";
          KillMode = "process";
          TimeoutSec = 180;
        };
      };

      fonts.fontDir.enable = true;

      # Backlight control
      programs.light.enable = true;
      programs.dconf.enable = true;

      security.polkit.enable = true;
      security.rtkit.enable = true; # Recommended for pipewire

      services.flatpak.enable = true;
      # Audio
      services.pipewire.enable = true;
      services.pipewire.alsa.enable = true;
      services.pipewire.alsa.support32Bit = true;
      services.pipewire.pulse.enable = true;
      services.pipewire.wireplumber.enable = true;
      # Dbus
      services.dbus.enable = true;

      # XDG portals
      xdg.portal.enable = true;
      xdg.portal.wlr.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      xdg.portal.config.preferred.default = "wlr"; # Default to wlr
      xdg.portal.config.preferred."org.freedesktop.impl.portal.FileChooser" = "gtk"; # But choose files with "gtk"

      hardware.opengl.enable = true;
      hardware.uinput.enable = true;
      hardware.steam-hardware.enable = cfg.steamHardwareSupport;
    })
    (lib.mkIf cfg."8bitdoFix" {
      # Udev rules to start or stop systemd service when controller is connected or disconnected
      services.udev.extraRules = ''
        # May vary depending on your controller model, find product id using 'lsusb'
        SUBSYSTEM=="usb", ATTR{idVendor}=="2dc8", ATTR{idProduct}=="3106", ATTR{manufacturer}=="8BitDo", RUN+="${pkgs.systemd}/bin/systemctl start 8bitdo-ultimate-xinput@2dc8:3106"
        # This device (2dc8:3016) is "connected" when the above device disconnects
        SUBSYSTEM=="usb", ATTR{idVendor}=="2dc8", ATTR{idProduct}=="3016", ATTR{manufacturer}=="8BitDo", RUN+="${pkgs.systemd}/bin/systemctl stop 8bitdo-ultimate-xinput@2dc8:3106"
      '';

      # Systemd service which starts xboxdrv in xbox360 mode
      systemd.services."8bitdo-ultimate-xinput@" = {
        unitConfig.Description = "8BitDo Ultimate Controller XInput mode xboxdrv daemon";
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.xboxdrv}/bin/xboxdrv --mimic-xpad --silent --type xbox360 --device-by-id %I --force-feedback";
        };
      };
    })
  ];
}
