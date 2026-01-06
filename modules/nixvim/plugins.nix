{ lib, pkgs, ... }:
let
  inherit (lib.nixvim) mkRaw;
in
{
  config = {
    extraPlugins = [
      pkgs.vimPlugins.blink-cmp-conventional-commits
      pkgs.vimPlugins.blink-cmp-spell
    ];

    plugins = {
      blink-cmp = {
        enable = true;
        settings = {
          sources = {
            default = [
              "lsp"
              "snippets"
              # "calc" # I should make  a plugin
              "path"
              "buffer"
              "spell"
            ];
            per_filetype.lua = mkRaw ''{ inherit_defaults = true, "lazydev" }'';
            providers = {
              # calc
              # Commit message suggestions
              conventional_commits = {
                name = "Conventional Commits";
                module = "blink-cmp-conventional-commits";
                # Only enable on commit messages
                enabled = mkRaw ''
                  function()
                    return vim.bo.filetype == "gitcommit" or vim.bo.filetype == "jjdescription"
                  end
                '';
              };
              # Neovim specific lua stuff
              lazydev = {
                name = "LazyDev";
                module = "lazydev.integrations.blink";
                score_offset = 100;
              };
              # Spelling suggestions
              spell = {
                name = "Spell";
                module = "blink-cmp-spell";
              };
            };
          };
          keymap = {
            preset = "default";
            "<C-n>" = [
              "select_next"
              "snippet_forward"
              "fallback"
            ];
            "<C-p>" = [
              "select_prev"
              "snippet_backward"
              "fallback"
            ];
            "<C-d>" = [
              "scroll_documentation_up"
              "fallback"
            ];
            "<C-f>" = [
              "scroll_documentation_down"
              "fallback"
            ];
            "<C-Space>" = [
              "show"
              "fallback"
            ];
            "<C-e>" = [
              "cancel"
              "fallback"
            ];
            "<CR>" = [
              "select_and_accept"
              "fallback"
            ];
          };
        };
      };
      gitsigns.enable = true;
      lazydev.enable = true;
      lualine = {
        enable = true;
        settings.options.theme = lib.mkForce "gruvbox";
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
  };
}
