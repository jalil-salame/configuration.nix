{
  enable = true;
  # Snippets
  snippet.luasnip.enable = true;
  # Completion Sources
  sources = {
    buffer.enable = true;
    buffer.groupIndex = 3;
    calc.enable = true;
    calc.groupIndex = 2;
    conventionalcommits.enable = true;
    conventionalcommits.groupIndex = 1;
    # cmdline.enable = true;
    crates.enable = true;
    crates.groupIndex = 1;
    digraphs.enable = true;
    digraphs.groupIndex = 3;
    # emoji.enable = true;
    # fuzzy_buffer.enable = true;
    # fuzzy_path.enable = true;
    luasnip.enable = true;
    luasnip.groupIndex = 1;
    nvim_lsp.enable = true;
    nvim_lsp.groupIndex = 1;
    nvim_lsp_document_symbol.enable = true;
    nvim_lsp_document_symbol.groupIndex = 1;
    nvim_lsp_signature_help.enable = true;
    nvim_lsp_signature_help.groupIndex = 1;
    path.enable = true;
    path.groupIndex = 2;
    # rg.enable = true;
    spell.enable = true;
    spell.groupIndex = 2;
    treesitter.enable = true;
    treesitter.groupIndex = 2;
    zsh.enable = true;
    zsh.groupIndex = 1;
  };
  # Menu Icons
  formatting.format = "require('lspkind').cmp_format { mode = 'symbol', maxwidth = 50 }";
  mappingPresets = [ "insert" ];
  mapping = {
    "<C-n>" = {
      modes = [ "i" "s" ];
      action = ''
        function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif require("luasnip").expand_or_jumpable() then
            require("luasnip").expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end
      '';
    };
    "<C-p>" = {
      modes = [ "i" "s" ];
      action = ''
        function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif require("luasnip").jumpable(-1) then
            require("luasnip").jump(-1)
          else
            fallback()
          end
        end
      '';
    };
    "<C-u>" = ''
      cmp.mapping(function(fallback)
        if require("luasnip").choice_active() then
          require("luasnip").next_choice()
        else
          fallback()
        end
      end)
    '';
    "<C-b>" = "cmp.mapping.scroll_docs(-4)";
    "<C-f>" = "cmp.mapping.scroll_docs(4)";
    "<C-Space>" = "cmp.mapping.complete {}";
    "<C-e>" = "cmp.mapping.close()";
    "<CR>" = "cmp.mapping.confirm { select = true }";
  };
}
