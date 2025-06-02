{ inputs, lib, ... }:
{
  flake = {
    # Example vm configuration
    nixosConfigurations.vm = lib.nixosSystem {
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
    homeConfigurations.example = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        inputs.self.homeModules.standalone
        ../example-hm/home.nix # import home-manager configuration
        {
          nixpkgs.overlays = [
            inputs.self.overlays.unstable
            inputs.lix-module.overlays.default
          ];
        }
      ];
    };
  };
}
