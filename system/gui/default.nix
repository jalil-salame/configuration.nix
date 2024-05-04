{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.jconfig.gui;
  enable = config.jconfig.enable && cfg.enable;
in {
  config = lib.mkMerge [
    (lib.mkIf enable {
      environment.systemPackages =
        [
          pkgs.gnome.adwaita-icon-theme
          pkgs.adwaita-qt
          pkgs.nordzy-cursor-theme
          pkgs.pinentry-qt
        ]
        ++ lib.optional cfg.ydotool.enable pkgs.ydotool;

      systemd.user.services.ydotool = lib.mkIf cfg.ydotool.enable {
        enable = cfg.ydotool.autoStart;
        wantedBy = ["default.target"];
        description = "Generic command-line automation tool";
        documentation = [
          "man:ydotool(1)"
          "man:ydotoold(8)"
        ];
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          ExecStart = "${pkgs.ydotool}/bin/ydotoold";
          ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";
          KillMode = "process";
          TimeoutSec = 180;
        };
      };
      # Fix xdg-portals issue issue: https://github.com/NixOS/nixpkgs/issues/189851
      systemd.user.extraConfig = ''
        DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
      '';

      fonts.fontDir.enable = true;

      programs.dconf.enable = true;

      programs.sway.enable = cfg.sway;
      programs.sway.extraPackages = []; # No extra packages (by default it adds foot, dmenu, and other stuff)
      programs.sway.wrapperFeatures.base = true;
      programs.sway.wrapperFeatures.gtk = true;

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
      xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
      # Default to the gtk portal
      xdg.portal.config.preferred.default = "gtk";
      # Use wlr for screenshots and screen recording
      xdg.portal.config.preferred."org.freedesktop.impl.portal.Screenshot" = "wlr";
      xdg.portal.config.preferred."org.freedesktop.impl.portal.ScreenCast" = "wlr";
      # Consider using darkman like upstream

      hardware.opengl.enable = true;
      hardware.uinput.enable = true;
      hardware.steam-hardware.enable = cfg.steamHardwareSupport;
    })
    (lib.mkIf (enable && cfg."8bitdoFix") {
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
