{
  gitsigns.enable = true;
  lsp = {
    enable = true;
    servers = {
      bashls.enable = true;
      clangd.enable = true;
      html.enable = true;
      jsonls.enable = true;
      nil.enable = true;
      pyright.enable = true;
      rnix-lsp.enable = true;
      ruff-lsp.enable = true;
      taplo.enable = true;
      texlab.enable = true;
      typos-lsp.enable = true;
      typst-lsp.enable = true;
    };
  };
  lspkind.enable = true;
  lualine = {
    enable = true;
    theme = "gruvbox";
    sections = {
      lualine_a = [{ name = "mode"; }];
      lualine_b = [{ name = "filename"; } { name = "branch"; }];
      lualine_y = [{ name = "encoding"; } { name = "fileformat"; } { name = "filetype"; }];
      lualine_z = [{ name = "location"; }];
    };
  };
  luasnip = {
    enable = true;
    extraConfig = { update_events = "TextChanged,TextChangedI"; };
  };
  nvim-cmp = import ./cmp.nix;
  nvim-colorizer = {
    enable = true;
    userDefaultOptions = {
      names = false; # disable named colors (i.e. red)
      mode = "virtualtext";
    };
  };
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
