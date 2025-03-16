{ lib, config, ... }:
let
  cfg = config.jhome.nvim;
in
{
  imports = [ ./options.nix ];

  config.programs.nixvim = lib.mkMerge [
    (import ./standalone.nix)
    (lib.mkIf cfg.enable {
      enable = true;
      nixpkgs.useGlobalPackages = true;
      defaultEditor = lib.mkDefault true;
      jhome.nvim = cfg;
    })
  ];
}
