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
        extraSpecialArgs = {
          inherit (inputs) unstable;
          inherit system;
        };
        module = import ../nvim/standalone.nix { standalone = true; };
      };
    in
    {
      # Check standalone nvim build
      checks.nvim = nixvimLib.check.mkTestDerivationFromNixvimModule module;

      # Nvim standalone module
      packages.nvim = nixvim.makeNixvimWithModule module;
    };
}
