{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules =
    let
      nixosModule = {
        imports = [
          inputs.stylix.nixosModules.stylix
          inputs.home-manager.nixosModules.home-manager
          ../modules/nixos
        ]
        ++ lib.optional (inputs.lix-module != null) inputs.lix-module.nixosModules.default;
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = [ self.homeModules.nixos ];
        };
        # Pin nixpkgs
        nix.registry.nixpkgs.flake = inputs.nixpkgs;
      };
    in
    {
      default = nixosModule;
      inherit nixosModule;
    };
}
