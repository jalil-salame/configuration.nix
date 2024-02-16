{ lib, ... }: {
  options.jhome.nvim.enable = lib.mkEnableOption "jalil's neovim configuration" // { default = true; example = false; };
}
