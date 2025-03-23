{ inputs, lib, ... }:
let
  system = "x86_64-linux";
  overlays = builtins.attrValues inputs.self.overlays;
  config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "steam-unwrapped" ];
  pkgs = import inputs.nixpkgs { inherit system overlays config; };
in
{
  # Example vm configuration
  flake.nixosConfigurations.vm = lib.nixosSystem {
    inherit pkgs;
    modules = [
      inputs.self.nixosModules.default
      ../example-vm # import vm configuration
      { nix.registry.nixpkgs.flake = inputs.nixpkgs; } # pin nixpkgs to the one used by the system
    ];
  };

}
