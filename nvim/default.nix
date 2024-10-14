{ system, unstable }:
{ lib, config, ... }:
let
  cfg = config.jhome.nvim;
in
{
  imports = [ ./options.nix ];

  config.programs.nixvim = lib.mkMerge [
    (import ./standalone.nix { standalone = false; })
    (lib.mkIf cfg.enable {
      nixpkgs = lib.mkForce { pkgs = import unstable { inherit system; }; };
      enable = true;
      defaultEditor = lib.mkDefault true;
    })
  ];
}
