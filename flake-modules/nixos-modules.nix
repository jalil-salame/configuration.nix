{ inputs, lib, ... }:
{
  flake.nixosModules =
    let
      nvim-config.imports = [
        inputs.nixvim.homeManagerModules.nixvim
        ../nvim
      ];
      homeManagerModuleSandalone = import ../home {
        inherit nvim-config;
        inherit (inputs) stylix;
      };
      homeManagerModuleNixOS = import ../home { inherit nvim-config; };
      nixosModule = {
        imports = [
          (import ../system { inherit (inputs) stylix; })
          inputs.home-manager.nixosModules.home-manager
        ] ++ lib.optional (inputs.lix-module != null) inputs.lix-module.nixosModules.default;
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = [ homeManagerModuleNixOS ];
        };
        # Pin nixpkgs
        nix.registry.nixpkgs.flake = inputs.nixpkgs;
      };

      machines = [ "vm" ];
      mkMachine = hostname: {
        imports = [
          nixosModule
          (import (../machines + "/${hostname}"))
        ];
        home-manager.sharedModules = [ { jhome.hostName = hostname; } ];
      };
      machineModules = lib.genAttrs machines mkMachine;
    in
    {
      default = nixosModule;
      inherit nixosModule homeManagerModuleNixOS homeManagerModuleSandalone;
    }
    // machineModules;
}
