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
      colorschemes.gruvbox.enable = true;
      colorschemes.gruvbox.settings.bold = true;
      colorschemes.gruvbox.settings.transparent_mode = true;
      colorschemes.gruvbox.settings.terminal_colors = true;
      options.number = true;
      options.relativenumber = true;
      options.colorcolumn = "+1";
      options.cursorline = true;
      options.wrap = false;
      options.splitright = true;
      # Tabs & indentation
      options.smarttab = true;
      options.autoindent = true;
      options.smartindent = true;
      # Search path
      options.path = ".,/usr/include,**";
      options.wildmenu = true;
      options.hlsearch = true;
      options.incsearch = true;
      options.ignorecase = true; # Search ignores cases
      options.smartcase = true; # Unless it has a capital letter
      # Enable local configuration :h 'exrc'
      options.exrc = true; # safe since nvim 0.9
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
      extraConfigLuaPost = ''
        -- Lua Post Config
        do -- Setup cmp-cmdline
          local cmp = require "cmp"
          cmp.setup.cmdline("/", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources { {name = "rg" }, { name = "buffer" } },
          })
          cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } })
          })
        end
      '';
    })
  ];
}
