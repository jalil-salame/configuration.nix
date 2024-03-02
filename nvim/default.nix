{ pkgs, config, lib, ... }:
let
  cfg = config.jhome.nvim;
in
{
  imports = [
    ./options.nix
  ];

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      package = pkgs.neovim-nightly;
      defaultEditor = true;
      globals.mapleader = " ";
      # Appearance
      colorschemes.gruvbox-nvim.enable = true;
      colorschemes.gruvbox-nvim.bold = true;
      colorschemes.gruvbox-nvim.transparentBg = true;
      colorschemes.gruvbox-nvim.trueColor = true;
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
      plugins = import ./plugins;
      mappings = import ./mappings.nix;
      augroups = import ./augroups.nix;
      extraPlugins =
        (with pkgs.vimExtraPlugins; [
          dressing-nvim
          rustaceanvim
          idris2-nvim
          nui-nvim
          nvim-lint
        ])
        ++ (with pkgs.vimPlugins; [
          lualine-lsp-progress
          nvim-web-devicons
          FTerm-nvim
          cmp-cmdline
          formatter-nvim
        ]);
      # Formatting
      extraPackages = with pkgs; [
        stylua
        shfmt
        taplo
        yamlfmt
        nixpkgs-fmt
        rust-analyzer
      ];
      extraLuaPreConfig = ''
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
      extraLuaPostConfig = ''
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

        do -- Setup dressing.nvim
          -- require("dressing").setup()
        end

        do -- Setup formatter.nvim
          -- local util = require "formatter.util"
          require("formatter").setup {
            logging = true,
            log_level = vim.log.levels.WARN,
            ["*"] = { require("formatter.filetypes.any").remove_trailing_whitespace },
            -- Filetype Formatting
            c = { require("formatter.filetypes.c").clangformat },
            sh = { require("formatter.filetypes.sh").shfmt },
            cpp = { require("formatter.filetypes.cpp").clangformat },
            lua = { require("formatter.filetypes.lua").stylua },
            nix = { require("formatter.filetypes.nix").nixpkgs_fmt },
            zig = { require("formatter.filetypes.zig").zigfmt },
            rust = { require("formatter.filetypes.rust").rustfmt },
            toml = { require("formatter.filetypes.toml").taplo },
            yaml = { require("formatter.filetypes.yaml").yamlfmt },
          }
        end

        do -- Setup idris2-nvim
          require("idris2").setup { }
        end

        do -- Setup nvim-lint
          require("lint").linters_by_ft = {
            latex = { "chktex", "typos" },
          }
        end
      '';
    };
  };
}
