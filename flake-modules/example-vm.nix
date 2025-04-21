{ inputs, lib, ... }:
{
  # Example vm configuration
  flake.nixosConfigurations.vm = lib.nixosSystem {
    modules = [
      inputs.self.nixosModules.default
      ../example-vm # import vm configuration
      {
        nixpkgs = {
          overlays = builtins.attrValues inputs.self.overlays;
          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "steam-unwrapped" ];
        };
        # pin nixpkgs to the one used by the system
        nix.registry.nixpkgs.flake = inputs.nixpkgs;
      }
    ];
  };
}
