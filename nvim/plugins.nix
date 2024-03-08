{ lib }: {
  cmp = {
    enable = true;
    cmdline = {
      "/" = {
        mapping.__raw = "cmp.mapping.preset.cmdline()";
        sources = [{ name = "rg"; } { name = "buffer"; }];
      };
      ":" = {
        mapping.__raw = "cmp.mapping.preset.cmdline()";
        sources = [{ name = "path"; } { name = "cmdline"; }];
      };
    };
    settings = {
      # Snippets
      snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
      # Completion Sources
      sources = [
        { name = "buffer"; groupIndex = 3; }
        { name = "calc"; groupIndex = 2; }
        { name = "conventionalcommits"; groupIndex = 1; }
        { name = "crates"; groupIndex = 1; }
        { name = "luasnip"; groupIndex = 1; }
        { name = "nvim_lsp"; groupIndex = 1; }
        { name = "nvim_lsp_document_symbol"; groupIndex = 1; }
        { name = "nvim_lsp_signature_help"; groupIndex = 1; }
        { name = "path"; groupIndex = 2; }
        { name = "spell"; groupIndex = 2; }
        { name = "treesitter"; groupIndex = 2; }
        { name = "zsh"; groupIndex = 1; }
      ];
      mapping.__raw = ''
        cmp.mapping.preset.insert({
          ["<C-n>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif require("luasnip").expand_or_jumpable() then
              require("luasnip").expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end,
          ["<C-p>"] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif require("luasnip").jumpable(-1) then
              require("luasnip").jump(-1)
            else
              fallback()
            end
          end,
          ["<C-u>"] = cmp.mapping(function(fallback)
            if require("luasnip").choice_active() then
              require("luasnip").next_choice()
            else
              fallback()
            end
          end),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete { },
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm { select = true },
        })
      '';
    };
  };
  conform-nvim = {
    enable = true;
    formattersByFt = {
      "_" = [ "trim_whitespace" ];
      c = [ "clang_format" ];
      cpp = [ "clang_format" ];
      lua = [ "stylua" ];
      nix = [ "nixpkgs_fmt" ];
      rust = [ "rustfmt" ];
      sh = [ "shfmt" ];
      toml = [ "taplo" ];
      yaml = [ "yamlfmt" ];
      zig = [ "zigfmt" ];
    };
  };
  gitsigns.enable = true;
  lsp = {
    enable = true;
    servers = {
      bashls.enable = true;
      clangd.enable = true;
      html.enable = true;
      jsonls.enable = true;
      nil_ls.enable = true;
      pyright.enable = true;
      rnix-lsp.enable = true;
      ruff-lsp.enable = true;
      taplo.enable = true;
      texlab.enable = true;
      typos-lsp.enable = true;
      typst-lsp.enable = true;
    };
  };
  lspkind = {
    enable = true;
    mode = "symbol";
    extraOptions.maxwidth = 50;
  };
  lualine = {
    enable = true;
    theme = lib.mkForce "gruvbox";
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
  noice = {
    enable = true;
    presets = {
      # use a classic bottom cmdline for search
      bottom_search = true;
      # position the cmdline and popupmenu together
      command_palette = true;
      # long messages will be sent to a split
      long_message_to_split = true;
      # enables an input dialog for inc-rename.nvim
      inc_rename = false;
      # add a border to hover docs and signature help
      lsp_doc_border = false;
    };
  };
  nvim-colorizer = {
    enable = true;
    userDefaultOptions = {
      names = false; # disable named colors (i.e. red)
      mode = "virtualtext";
    };
  };
  rustaceanvim.enable = true;
  telescope = {
    enable = true;
    extensions = {
      ui-select.enable = true;
      fzy-native.enable = true;
    };
  };
  treesitter = {
    enable = true;
    indent = true;
    incrementalSelection.enable = true;
  };
  treesitter-context.enable = true;
  trouble = {
    enable = true;
    autoClose = true;
  };
  lint = {
    enable = true;
    lintersByFt = {
      rust = [ "typos" ];
      latex = [ "chktex" "typos" ];
      markdown = [ "typos" ];
    };
  };
}
