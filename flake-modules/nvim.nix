{ inputs, lib, ... }:
{
  flake.overlays.nixvim = inputs.nixvim.overlays.default;

  perSystem =
    { pkgs, system, ... }:
    let
      nixvimLib = inputs.nixvim.lib.${system};
      nixvim = inputs.nixvim.legacyPackages.${system};
      testNvimModule = nixvimLib.check.mkTestDerivationFromNixvimModule;
      nvimModule = extraConfig: {
        inherit pkgs;
        extraSpecialArgs = {
          inherit (inputs) unstable;
          inherit system;
        };
        module = {
          imports = [ (import ../nvim/standalone.nix { standalone = true; }) ];
          config = extraConfig;
        };
      };
      moduleDev = nvimModule { };
      moduleHeadless = nvimModule { jhome.nvim.dev.enable = false; };
      moduleNoLsp = nvimModule { jhome.nvim.dev.bundleLSPs = false; };
      moduleNoTSGrammars = nvimModule { jhome.nvim.dev.bundleGrammars = false; };
      moduleNoBundledBins = nvimModule {
        jhome.nvim.dev = {
          bundleLSPs = false;
          bundleGrammars = false;
        };
      };
    in
    {
      # Check standalone nvim build
      checks = {
        nvimDev = testNvimModule moduleDev;
        nvimHeadless = testNvimModule moduleHeadless;
        nvimNoLsp = testNvimModule moduleNoLsp;
        nvimNoTSGrammars = testNvimModule moduleNoTSGrammars;
        nvimNoBundledBins = testNvimModule moduleNoBundledBins;
      };

      # Nvim standalone module
      packages = {
        nvim = nixvim.makeNixvimWithModule moduleDev;
        # Smaller derivations
        nvim-small = nixvim.makeNixvimWithModule moduleNoBundledBins;
        nvim-no-ts = nixvim.makeNixvimWithModule moduleNoTSGrammars;
        nvim-no-lsps = nixvim.makeNixvimWithModule moduleNoLsp;
      };
    };
}
