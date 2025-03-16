{
  self,
  inputs,
  lib,
  ...
}:
let
  modules = ../modules;
in
{
  flake = {
    homeManagerModules =
      let
        defaultModules = [
          inputs.nixvim.homeManagerModules.nixvim
          self.nixvimModules.homeManager
          (modules + "/hm")
        ];
        nixos = {
          imports = defaultModules;
        };
        standalone = {
          imports = defaultModules ++ [
            inputs.stylix.homeManagerModules.stilyx
            (
              { config, ... }:
              {
                stylix.image = config.jhome.sway.background;
              }
            )
          ];
        };
      in
      {
        inherit standalone nixos;
      };
    nixosModules =
      let
        nixosModule = {
          imports = [
            inputs.stylix.nixosModules.stylix
            inputs.home-manager.nixosModules.home-manager
            (modules + "/nixos")
          ] ++ lib.optional (inputs.lix-module != null) inputs.lix-module.nixosModules.default;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [ self.homeManagerModules.nixos ];
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
        inherit nixosModule;
      }
      // machineModules;
  };
}
