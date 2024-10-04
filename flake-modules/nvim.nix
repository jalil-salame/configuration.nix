{ inputs, ... }:
let
  standalone = ../nvim/standalone.nix;
in
{
  flake.overlays.nixvim = inputs.nixvim.overlays.default;

  perSystem =
    { pkgs, system, ... }:
    {
      # Check standalone nvim build
      checks.nvim = inputs.nixvim.lib.${system}.check.mkTestDerivationFromNixvimModule {
        inherit pkgs;
        module = ../nvim/standalone.nix;
      };

      # Nvim standalone module
      packages.nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        module = standalone;
      };

    };
}
