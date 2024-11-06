{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
  mkDisableOption =
    desc:
    mkEnableOption desc
    // {
      default = true;
      example = false;
    };
in
{
  options.jhome.nvim = {
    enable = mkDisableOption "jalil's Neovim configuration";
    dev = mkOption {
      type = types.submodule {
        options = {
          enable = mkDisableOption "development configuration";
          bundleLSPs = mkDisableOption "bundling LSPs with Neovim (decreases size when disabled)";
          bundleGrammars = mkDisableOption "bundling treesitter grammars with Neovim (barely decreases size when disabled)";
        };
      };
      default = { };
      example = {
        enable = false;
      };
      description = ''
        Development options

        Disabling this is advised for headless setups (e.g. servers), where you
        won't be doing software development and would prefer to instead have a
        smaller package.
      '';
    };
  };
}
