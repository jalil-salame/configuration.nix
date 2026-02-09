{ lib, pkgs, ... }@args:
let
  cfg = args.config.jconfig.gui;
  enable = args.config.jconfig.enable && cfg.enable;
in
{
  config = lib.mkIf enable {
    programs.sway = {
      enable = cfg.sway;
      # No extra packages (by default it adds foot, dmenu, and other stuff)
      extraPackages = [ ];
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
    };

    # XDG portals
    xdg.portal = {
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.preferred = {
        # Default to the gtk portal
        default = "gtk";
        # Use wlr for screenshots and screen recording
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
      };
      # Consider using darkman like upstream
    };
  };
}
