{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.jhome.nvim;
  plugins = pkgs.vimPlugins;
  jExtraVimPlugins = pkgs.vimPlugins.extend (
    pkgs.callPackage ./extraPlugins/generated.nix {
      inherit (pkgs.vimUtils) buildVimPlugin;
      inherit (pkgs.neovimUtils) buildNeovimPlugin;
    }
  );
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
      ];
      extraConfigLuaPre =
        # lua
        ''
          -- START: Lua Pre Config
          if vim.fn.has 'termguicolors' then
            -- Enable RGB colors
            vim.g.termguicolors = true
          end
          -- END: Lua Pre Config
        '';
    }
  ];
}
