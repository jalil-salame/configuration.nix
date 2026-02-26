{ lib, pkgs, ... }@args:
let
  cfg = args.config.jconfig.styling;
  enable = args.config.jconfig.enable && cfg.enable;
  gui = args.config.jconfig.gui.enable;
in
{
  imports = [
    (import ../../shared/starship.nix { cfg = args.config.jconfig; })
  ];

  config = lib.mkIf enable {
    catppuccin = lib.mkMerge [
      { tty.enable = true; }
      (lib.mkIf gui {
        cursors.enable = true;
        gtk.icon.enable = true;
      })
    ];

    boot.plymouth = {
      inherit (cfg) enable;
      logo = cfg.bootLogo;
    };

    fonts = lib.mkIf gui {
      packages = [
        pkgs.jetbrains-mono
        pkgs.nerd-fonts.symbols-only
        pkgs.noto-fonts
        pkgs.noto-fonts-color-emoji
        # Chinese, Japanese and Korean characters
        pkgs.noto-fonts-cjk-sans
        pkgs.noto-fonts-cjk-serif
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          monospace = [
            "JetBrains Mono"
            "Symbols Nerd Font"
          ];
          sansSerif = [
            "Noto Sans"
            "Symbols Nerd Font"
          ];
          serif = [
            "Noto Serif"
            "Symbols Nerd Font"
          ];
        };
      };
    };
  };
}
