{ pkgs, lib, config, ... } @ args:
let
  cfg = config.jhome.nvim;
  hmAvailable = args ? hmConfig;
  nixosAvailable = args ? nixosConfig;
  darwinAvailable = args ? darwinConfig;
  canSetAsDefault = hmAvailable || nixosAvailable;
  notStandalone = hmAvailable || nixosAvailable || darwinAvailable;
in
{
  imports = [
    ./options.nix
  ];

  config = lib.mkMerge [
    (lib.optionalAttrs canSetAsDefault { defaultEditor = lib.mkDefault true; })
    (lib.optionalAttrs notStandalone { enable = lib.mkDefault true; })
    (lib.mkIf cfg.enable {
      package = pkgs.neovim-nightly;
      globals.mapleader = " ";
      # Appearance
      colorschemes = {
        gruvbox.enable = true;
        gruvbox.settings.bold = true;
        gruvbox.settings.transparent_mode = true;
        gruvbox.settings.terminal_colors = true;
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
      plugins = import ./plugins.nix { inherit lib; };
      keymaps = import ./mappings.nix;
      inherit (import ./augroups.nix) autoGroups autoCmd;
      extraPlugins = with pkgs.vimPlugins; [
        nvim-web-devicons
      ];
      # Formatting
      extraPackages = with pkgs; [
        stylua
        shfmt
        taplo
        yamlfmt
        nixpkgs-fmt
        rust-analyzer
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
    })
  ];
}
