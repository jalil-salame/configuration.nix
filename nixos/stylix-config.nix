{ config, pkgs }:
let
  cfg = config.jconfig.styling;
  # nerdFontSymbols = pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; };
  # fallbackSymbols = {
  #   name = "Symbols Nerd Font";
  #   package = nerdFontSymbols;
  # };
in
{
  autoEnable = cfg.enable;
  image = cfg.wallpaper;
  base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  polarity = "dark";
  fonts.monospace.name = "JetBrains Mono";
  fonts.monospace.package = pkgs.jetbrains-mono;
  fonts.sansSerif.name = "Noto Sans";
  fonts.sansSerif.package = pkgs.noto-fonts;
  fonts.serif.name = "Noto Serif";
  fonts.serif.package = pkgs.noto-fonts;
  # fonts.fallbackFonts.monospace = [ fallbackSymbols ];
  # fonts.fallbackFonts.sansSerif = [ fallbackSymbols ];
  # fonts.fallbackFonts.serif = [ fallbackSymbols ];
  fonts.sizes.popups = 12;
  targets.plymouth.logoAnimated = false;
  targets.plymouth.logo = cfg.bootLogo;
}
