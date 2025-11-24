{ lib, ... }:
let
  inherit (lib.nixvim) mkRaw;
in
{
  config.plugins = {
    cmp =
      let
        srcWithIndex = groupIndex: name: { inherit name groupIndex; };
      in
      {
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
                "cmp.mapping.preset.cmdline()";
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
            "function(args) require('luasnip').lsp_expand(args.body) end";
          # Completion Sources
          sources = [
            # very specific (not noisy)
            (srcWithIndex 1 "calc")
            (srcWithIndex 1 "crates")
            (srcWithIndex 1 "fish")
            (srcWithIndex 1 "luasnip")
            (srcWithIndex 1 "nvim_lsp")
            # Generally ok
            (srcWithIndex 2 "conventionalcommits")
            (srcWithIndex 2 "nvim_lsp_document_symbol")
            (srcWithIndex 2 "nvim_lsp_signature_help")
            # Noisy
            (srcWithIndex 2 "path")
            (srcWithIndex 3 "spell")
            (srcWithIndex 3 "treesitter")
            # Very noisy
            (srcWithIndex 4 "buffer")
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
    cmp-fish.enable = true;
    gitsigns.enable = true;
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
      settings = {
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
    };
    notify = {
      enable = true;
      settings.background_colour = "#000000";
    };
    telescope = {
      enable = true;
      extensions = {
        ui-select.enable = true;
        fzy-native.enable = true;
      };
    };
    trouble = {
      enable = true;
      settings.auto_close = true;
    };
    web-devicons.enable = true;
  };
}
