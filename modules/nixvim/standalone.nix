{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.jhome.nvim;
  plugins = pkgs.vimPlugins;
  extraPlugins = import ./extraPlugins { inherit pkgs; };
in
{
  imports = [
    ./options.nix
    ./plugins.nix
    ./dev-plugins.nix
    ./mappings.nix
    ./augroups.nix
  ];

  config = lib.mkMerge [
    {
      withRuby = false;
      globals.mapleader = " ";
      # Appearance
      colorschemes.gruvbox = {
        enable = true;
        settings = {
          bold = true;
          transparent_mode = true;
          terminal_colors = true;
        };
      };
      opts = {
        number = true;
        relativenumber = true;
        colorcolumn = "+1";
        cursorline = true;
        wrap = false;
        splitright = true;
        # Tabs & indentation
        smarttab = true;
        autoindent = true;
        smartindent = true;
        # Search path
        path = ".,/usr/include,**";
        wildmenu = true;
        hlsearch = true;
        incsearch = true;
        ignorecase = true; # Search ignores cases
        smartcase = true; # Unless it has a capital letter
        # Enable local configuration :h 'exrc'
        exrc = true; # safe since nvim 0.9
      };
      extraPlugins = [
        plugins.nui-nvim
        plugins.nvim-web-devicons
        plugins.vim-jjdescription # FIXME: included since neovim nightly
      ];
      extraPackages = [ pkgs.luajitPackages.jsregexp ];
      extraConfigLuaPre =
        # lua
        ''
          -- Lua Pre Config
          if vim.fn.has 'termguicolors' then
            -- Enable RGB colors
            vim.g.termguicolors = true
          end

          -- Useful function
          local has_words_before = function()
            -- unpack = unpack or table.unpack
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0
              and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
          end
          -- END: Lua Pre Config
        '';
    }
    # Big packages that are kinda unnecessary
    (lib.mkIf (!cfg.reduceSize) {
      extraPlugins = [ extraPlugins.nvim-silicon ];
      extraPackages = [ pkgs.silicon ];
      extraConfigLua =
        # lua
        ''
          -- Lua Config
          require("nvim-silicon").setup {
            theme = "gruvbox-dark",
            pad_horiz = 16,
            pad_vert = 16,
            -- Current buffer name
            window_title = function()
                return vim.fn.fnamemodify(
                    vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()),
                    ":t"
                )
            end,
          }
          -- END: Lua Config
        '';
    })
  ];
}
