{
  lib,
  pkgs,
  helpers,
  ...
}:
let
  inherit (helpers) mkRaw;
in
{
  config.plugins = {
    bacon = {
      enable = true;
      settings.quickfix.enabled = true;
    };
    cmp = {
      enable = true;
      cmdline = {
        "/" = {
          mapping =
            mkRaw
              # lua
              ''
                cmp.mapping.preset.cmdline()
              '';
          sources = [
            { name = "rg"; }
            { name = "buffer"; }
          ];
        };
        ":" = {
          mapping =
            mkRaw
              # lua
              ''
                cmp.mapping.preset.cmdline()
              '';
          sources = [
            { name = "path"; }
            { name = "cmdline"; }
          ];
        };
      };
      settings = {
        # Snippets
        snippet.expand =
          # lua
          ''
            function(args) require('luasnip').lsp_expand(args.body) end
          '';
        # Completion Sources
        sources = [
          {
            name = "buffer";
            groupIndex = 3;
          }
          {
            name = "calc";
            groupIndex = 2;
          }
          {
            name = "conventionalcommits";
            groupIndex = 1;
          }
          {
            name = "crates";
            groupIndex = 1;
          }
          {
            name = "luasnip";
            groupIndex = 1;
          }
          {
            name = "nvim_lsp";
            groupIndex = 1;
          }
          {
            name = "nvim_lsp_document_symbol";
            groupIndex = 1;
          }
          {
            name = "nvim_lsp_signature_help";
            groupIndex = 1;
          }
          {
            name = "path";
            groupIndex = 2;
          }
          {
            name = "spell";
            groupIndex = 2;
          }
          {
            name = "treesitter";
            groupIndex = 2;
          }
          {
            name = "zsh";
            groupIndex = 1;
          }
        ];
        mapping =
          mkRaw
            # lua
            ''
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
    # FIXME: doesn't include formatters
    conform-nvim = {
      enable = true;
      settings = {
        formatters.nixfmt.command = "${lib.getExe pkgs.nixfmt-rfc-style}";
        formatters_by_ft = {
          "_" = [ "trim_whitespace" ];
          c = [ "clang_format" ];
          cpp = [ "clang_format" ];
          lua = [ "stylua" ];
          nix = [ "nixfmt" ];
          rust = [ "rustfmt" ];
          sh = [ "shfmt" ];
          toml = [ "taplo" ];
          yaml = [ "yamlfmt" ];
          zig = [ "zigfmt" ];
        };
      };
    };
    gitsigns.enable = true;
    lint = {
      enable = true;
      lintersByFt = {
        latex = [ "chktex" ];
        nix = [ "statix" ];
        sh = [ "dash" ];
        zsh = [ "zsh" ];
      };
    };
    lsp = {
      enable = true;
      servers = {
        bashls = {
          enable = true;
          package = pkgs.unstable.bash-language-server;
        };
        # clangd.enable = true; # Adds ~2GiB
        # html.enable = true; # Not writing html
        jsonls.enable = true;
        marksman.enable = true;
        nixd.enable = true;
        nil_ls = {
          enable = true;
          settings.nix.flake = {
            autoArchive = true;
            autoEvalInputs = true;
          };
        };
        pyright.enable = true;
        ruff.enable = true;
        taplo.enable = true;
        # texlab.enable = true; # Not writing TeX rn
        typos_lsp.enable = true;
        # typst_lsp.enable = true; # Not using it either
      };
    };
    lspkind = {
      enable = true;
      mode = "symbol";
      extraOptions.maxwidth = 50;
    };
    lsp-lines.enable = true;
    lualine = {
      enable = true;
      settings.options.theme = lib.mkForce "gruvbox";
    };
    luasnip = {
      enable = true;
      settings.update_events = "TextChanged,TextChangedI";
    };
    noice = {
      enable = true;
      lsp.override = {
        "vim.lsp.util.convert_input_to_markdown_lines" = true;
        "vim.lsp.util.stylize_markdown" = true;
        "cmp.entry.get_documentation" = true;
      };
      presets = {
        # use a classic bottom cmdline for search
        bottom_search = true;
        # position the cmdline and popupmenu together
        command_palette = false;
        # long messages will be sent to a split
        long_message_to_split = true;
        # enables an input dialog for inc-rename.nvim
        inc_rename = false;
        # add a border to hover docs and signature help
        lsp_doc_border = true;
      };
    };
    notify = {
      enable = true;
      backgroundColour = "#000000";
    };
    nvim-colorizer = {
      enable = true;
      userDefaultOptions = {
        names = false; # disable named colors (i.e. red)
        mode = "virtualtext";
      };
    };
    rustaceanvim = {
      enable = true;
      # Install through rustup
      rustAnalyzerPackage = null;
    };
    telescope = {
      enable = true;
      extensions = {
        ui-select.enable = true;
        fzy-native.enable = true;
      };
    };
    treesitter = {
      enable = true;
      settings = {
        indent.enable = true;
        incremental_election.enable = true;
      };
    };
    trouble = {
      enable = true;
      settings.auto_close = true;
    };
    web-devicons.enable = true;
  };
}
