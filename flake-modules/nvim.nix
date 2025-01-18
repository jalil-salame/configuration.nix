{ inputs, ... }:
{
  flake.overlays.nixvim = inputs.nixvim.overlays.default;

  perSystem =
    { lib, system, ... }:
    let
      nixvimLib = inputs.nixvim.lib.${system};
      nixvim = inputs.nixvim.legacyPackages.${system};
      testNvimModule = nixvimLib.check.mkTestDerivationFromNixvimModule;
      nvimModule = extraConfig: {
        pkgs = inputs.unstable.legacyPackages.${system};
        module = {
          imports = [ ../nvim/standalone.nix ];
          config = lib.mkMerge [
            { performance.combinePlugins.enable = true; }
            extraConfig
          ];
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
        nvim-headless = nixvim.makeNixvimWithModule moduleHeadless;
        nvim-small = nixvim.makeNixvimWithModule moduleNoBundledBins;
        nvim-no-ts = nixvim.makeNixvimWithModule moduleNoTSGrammars;
        nvim-no-lsps = nixvim.makeNixvimWithModule moduleNoLsp;
      };
    };
}
