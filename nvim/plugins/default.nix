{
  colorizer.enable = true;
  colorizer.userDefaultOptions.names = false; # disable named colors (i.e. red)
  gitsigns.enable = true;
  lspconfig = import ./lspconfig.nix;
  lspkind.enable = true;
  lualine = import ./lualine.nix;
  luasnip.enable = true;
  luasnip.extraConfig = { update_events = "TextChanged,TextChangedI"; };
  nvim-cmp = import ./cmp.nix;
  telescope.enable = true;
  treesitter.enable = true;
  treesitter.indent = true;
  treesitter.incrementalSelection.enable = true;
  treesitter-context.enable = true;
  trouble.enable = true;
}
