{ lib, config, ... }:
let
  cfg = config.jhome.nvim;
in
{
  imports = [ ./options.nix ];

  config.programs.nixvim = lib.mkMerge [
    ./standalone.nix
    (lib.mkIf cfg.enable {
      enable = true;
      defaultEditor = lib.mkDefault true;
    })
  ];
}
