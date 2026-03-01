{ lib, config, ... }:
let
  cfg = config.jhome;
in
{
  config = lib.mkIf (cfg.enable && cfg.styling.enable) {
    catppuccin = lib.mkMerge [
      {
        bat.enable = true;
        btop.enable = true;
        delta.enable = true;
        eza.enable = true;
        fish.enable = true;
        fzf.enable = true;
        zellij.enable = true;
      }
      (lib.mkIf cfg.gui.enable {
        alacritty.enable = true;
        cursors.enable = true;
        fuzzel.enable = true;
        mako.enable = true;
        mpv.enable = true;
        zathura.enable = true;
      })
    ];
  };
}
