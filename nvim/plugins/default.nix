{
  colorizer = {
    enable = true;
    # disable named colors (i.e. red)
    userDefaultOptions.names = false;
  };
  gitsigns.enable = true;
  lspconfig = import ./lspconfig.nix;
  lspkind.enable = true;
  lualine = import ./lualine.nix;
  luasnip = {
    enable = true;
    extraConfig = { update_events = "TextChanged,TextChangedI"; };
  };
  nvim-cmp = import ./cmp.nix;
  telescope.enable = true;
  treesitter = {
    enable = true;
    indent = true;
    incrementalSelection.enable = true;
  };
  treesitter-context.enable = true;
  trouble.enable = true;
  lint = {
    enable = true;
    lintersByFt = {
      rust = [ "typos" ];
      latex = [ "chktex" "typos" ];
      markdown = [ "typos" ];
    };
  };
}
