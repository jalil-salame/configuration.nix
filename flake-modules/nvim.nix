{ inputs, lib, ... }:
{
  flake.overlays.nixvim = inputs.nixvim.overlays.default;

  perSystem =
    { pkgs, system, ... }:
    let
      nixvimLib = inputs.nixvim.lib.${system};
      nixvim = inputs.nixvim.legacyPackages.${system};
      moduleDev = {
        inherit pkgs;
        extraSpecialArgs = {
          inherit (inputs) unstable;
          inherit system;
        };
        module = import ../nvim/standalone.nix { standalone = true; };
      };
      moduleHeadless = {
        inherit pkgs;
        extraSpecialArgs = {
          inherit (inputs) unstable;
          inherit system;
        };
        module = {
          imports = [ (import ../nvim/standalone.nix { standalone = true; }) ];
          config.jhome.nvim.dev.enable = false;
        };
      };
    in
    {
      # Check standalone nvim build
      checks.nvimDev = nixvimLib.check.mkTestDerivationFromNixvimModule moduleDev;
      checks.nvimHeadless = nixvimLib.check.mkTestDerivationFromNixvimModule moduleHeadless;

      # Nvim standalone module
      packages.nvim = nixvim.makeNixvimWithModule moduleDev;
    };
}
