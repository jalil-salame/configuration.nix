{ lib, pkgs, ... }@args:
let
  cfg = args.config.jconfig.gui;
  enable = args.config.jconfig.enable && cfg.enable;
  linuxOlderThan6_3 = lib.versionOlder args.config.boot.kernelPackages.kernel.version "6.3";
in
{
  imports = [ ./sway.nix ];

  config = lib.mkIf enable (
    lib.mkMerge [
      {
        environment.systemPackages = [
          pkgs.adwaita-icon-theme
          pkgs.adwaita-qt
          pkgs.nordzy-cursor-theme
          pkgs.pinentry-qt
        ];
        # Fix xdg-portals issue issue: https://github.com/NixOS/nixpkgs/issues/189851
        systemd.user.extraConfig = ''
          DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
        '';

        fonts.fontDir.enable = true;
        programs.dconf.enable = true;
        security = {
          polkit.enable = true;
          rtkit.enable = true; # Recommended for pipewire
        };
        services = {
          flatpak.enable = true;
          # Audio
          pipewire = {
            enable = true;
            alsa = {
              enable = true;
              support32Bit = true;
            };
            pulse.enable = true;
            wireplumber.enable = true;
          };
          # Dbus
          dbus.enable = true;
          # Virtual Filesystem (for PCManFM)
          gvfs.enable = true;
        };
        xdg.portal.enable = true;
        hardware = {
          graphics.enable = true;
          uinput.enable = true;
          steam-hardware.enable = cfg.steamHardwareSupport;
        };
        # Open ports for spotifyd
        networking.firewall = {
          allowedUDPPorts = [ 5353 ];
          allowedTCPPorts = [ 2020 ];
        };
      }
      (lib.mkIf cfg.ydotool.enable {
        environment.systemPackages = [ pkgs.ydotool ];
        systemd.user.services.ydotool = {
          enable = cfg.ydotool.autoStart;
          wantedBy = [ "default.target" ];
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
      })
      (lib.mkIf (linuxOlderThan6_3 && cfg."8bitdoFix") {
        # Udev rules to start or stop systemd service when controller is connected or disconnected
        services.udev.extraRules = # udev
          ''
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
    ]
  );
}
