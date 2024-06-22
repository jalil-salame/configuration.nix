{
  pkgs,
  lib,
  config,
  ...
} @ args: let
  cfg = config.jhome.nvim;
  hmAvailable = args ? hmConfig;
  nixosAvailable = args ? nixosConfig;
  darwinAvailable = args ? darwinConfig;
  canSetAsDefault = hmAvailable || nixosAvailable;
  notStandalone = hmAvailable || nixosAvailable || darwinAvailable;
  augroups = import ./augroups.nix args;
in {
  imports = [./options.nix];

  config = lib.mkMerge [
    (lib.optionalAttrs canSetAsDefault {defaultEditor = lib.mkDefault true;})
    (lib.optionalAttrs notStandalone {enable = lib.mkDefault true;})
    (lib.mkIf cfg.enable {
      package = pkgs.unstable.neovim-unwrapped;
      inherit (augroups) autoGroups autoCmd;
      plugins = import ./plugins.nix args;
      keymaps = import ./mappings.nix args;
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
      clipboard.providers.wl-copy.enable = true;
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
      extraPlugins = let
        plugins = pkgs.unstable.vimPlugins;
        extraPlugins = import ./extraPlugins {pkgs = pkgs.unstable;};
      in [
        plugins.nui-nvim
        plugins.nvim-web-devicons
        extraPlugins.vim-jjdescription
        extraPlugins.nvim-silicon
      ];
      # Formatting & linters
      extraPackages = [
        pkgs.unstable.silicon
        pkgs.unstable.alejandra
        pkgs.unstable.luajitPackages.jsregexp
        pkgs.unstable.statix
        pkgs.unstable.stylua
        pkgs.unstable.shfmt
        pkgs.unstable.taplo
        pkgs.unstable.typos
        pkgs.unstable.yamlfmt
      ];
      extraConfigLuaPre = ''
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
      extraConfigLua = ''
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
