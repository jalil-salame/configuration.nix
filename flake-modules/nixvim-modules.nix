{ self, inputs, ... }:
{
  imports = [ inputs.nixvim.flakeModules.default ];

  nixvim = {
    packages.enable = true;
    checks.enable = false; # FIXME: borked due to nix-community/nixvim#3074
  };

  flake.nixvimModules =
    let
      module = ../modules/nixvim;
    in
    {
      standalone = "${module}/standalone.nix";
      homeManager = module;
    };

  perSystem =
    { system, ... }:
    let
      nvimModule = extraConfig: {
        inherit system;
        modules = [
          self.nixvimModules.standalone
          # FIXME: borked due to https://github.com/nix-community/nixvim/issues/3140
          # { performance.combinePlugins.enable = true; }
          extraConfig
        ];
      };
      modules = {
        nvim = nvimModule { };
        # Smaller derivations
        nvim-headless = nvimModule {
          jhome.nvim.dev.enable = false;
          jhome.nvim.reduceSize = true;
        };
        nvim-small = nvimModule {
          jhome.nvim.dev.bundleLSPs = false;
        };
        nvim-no-ts = nvimModule {
          jhome.nvim.dev.bundleGrammars = false;
        };
        nvim-no-lsps = nvimModule {
          jhome.nvim.dev = {
            bundleLSPs = false;
            bundleGrammars = false;
          };
        };
      };
    in
    {
      checks = builtins.mapAttrs (
        _name: module:
        inputs.nixvim.lib.${system}.check.mkTestDerivationFromNixvimModule {
          module.imports = module.modules;
        }
      ) modules;

      nixvimConfigurations = builtins.mapAttrs (_name: inputs.nixvim.lib.evalNixvim) modules;
    };
}
