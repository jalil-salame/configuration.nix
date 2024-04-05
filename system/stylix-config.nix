{ config, pkgs }:
let
  cfg = config.jconfig.styling;
  nerdFontSymbols = pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; };
  fallbackSymbols = {
    name = "Symbols Nerd Font";
    package = nerdFontSymbols;
  };
in
{
  autoEnable = cfg.enable;
  image = cfg.wallpaper;
  base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  polarity = "dark";
  fonts.monospace = [
    {
      name = "JetBrains Mono";
      package = pkgs.jetbrains-mono;
    }
    fallbackSymbols
  ];
  fonts.sansSerif = [
    {
      name = "Noto Sans";
      package = pkgs.noto-fonts;
    }
    fallbackSymbols
  ];
  fonts.serif = [
    {
      name = "Noto Serif";
      package = pkgs.noto-fonts;
    }
    fallbackSymbols
  ];
  fonts.emoji = {
    package = pkgs.noto-fonts-emoji;
    name = "Noto Color Emoji";
  };
  fonts.sizes.popups = 12;
  targets.plymouth.logoAnimated = false;
  targets.plymouth.logo = cfg.bootLogo;
}
