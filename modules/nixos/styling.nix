{ lib, pkgs, ... }@args:
let
  cfg = args.config.jconfig.styling;
  enable = args.config.jconfig.enable && cfg.enable;
in
{
  config = lib.mkIf enable {
    boot.plymouth = { inherit (cfg) enable; };

    stylix = {
      inherit (cfg) enable;
      image = cfg.wallpaper;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
      polarity = "dark";
      fonts = {
        monospace = {
          name = "JetBrains Mono";
          package = pkgs.jetbrains-mono;
        };
        sansSerif = {
          name = "Noto Sans";
          package = pkgs.noto-fonts;
        };
        serif = {
          name = "Noto Serif";
          package = pkgs.noto-fonts;
        };
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
        sizes.popups = 12;
      };
      targets = {
        plymouth = {
          logoAnimated = false;
          logo = cfg.bootLogo;
        };
        nixvim.enable = false;
      };
    };
  };
}
