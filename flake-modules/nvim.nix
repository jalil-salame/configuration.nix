{ inputs, ... }:
{
  flake.overlays.nixvim = inputs.nixvim.overlays.default;

  perSystem =
    { pkgs, system, ... }:
    let
      nixvimLib = inputs.nixvim.lib.${system};
      nixvim = inputs.nixvim.legacyPackages.${system};
      module = {
        inherit pkgs;
        module = ../nvim/standalone.nix;
      };
    in
    {
      # Check standalone nvim build
      checks.nvim = nixvimLib.check.mkTestDerivationFromNixvimModule module;

      # Nvim standalone module
      packages.nvim = nixvim.makeNixvimWithModule module;
    };
}
