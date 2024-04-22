{
  autoGroups."highlightOnYank" = { };
  autoGroups."lspConfig" = { };
  autoGroups."restoreCursorPosition" = { };
  autoCmd = [
    {
      group = "highlightOnYank";
      event = "TextYankPost";
      pattern = "*";
      callback = {
        __raw = ''
          function()
            vim.highlight.on_yank {
              higroup = (
                vim.fn['hlexists'] 'HighlightedyankRegion' > 0 and 'HighlightedyankRegion' or 'IncSearch'
              ),
              timeout = 200,
            }
          end
        '';
      };
    }
    {
      group = "restoreCursorPosition";
      event = "BufReadPost";
      pattern = "*";
      callback = {
        __raw = ''
          function()
            if vim.fn.line '\'"' > 0 and vim.fn.line '\'"' <= vim.fn.line '$' then
              vim.cmd [[execute "normal! g'\""]]
            end
          end
        '';
      };
    }
    {
      group = "lspConfig";
      event = "LspAttach";
      pattern = "*";
      callback =
        let
          opts = "noremap = true, buffer = bufnr";
        in
        {
          __raw = ''
            function(opts)
              local bufnr = opts.buf
              local client = vim.lsp.get_client_by_id(opts.data.client_id)
              local capabilities = client.server_capabilities
              -- Set Omnifunc if supported
              if capabilities.completionProvider then
                vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
              end
              -- Enable inlay hints if supported
              if capabilities.inlayHintProvider then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
              end
              -- Some Lsp servers do not advertise inlay hints properly so enable this keybinding regardless
              vim.keymap.set('n', '<space>ht', function()
                  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(0), { bufnr = 0 })
                end,
                { desc = '[H]ints [T]oggle', ${opts} }
              )
              -- Enable hover if supported
              if capabilities.hoverProvider then
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation', ${opts} })
              end
              -- Enable rename if supported
              if capabilities.renameProvider then
                vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { desc = '[R]ename', ${opts} })
              end
              -- Enable code actions if supported
              if capabilities.codeActionProvider then
                vim.keymap.set({ 'n', 'v' }, '<leader>fa', vim.lsp.buf.code_action, { desc = '[F]ind Code [A]ctions', ${opts} })
              end
              -- Enable formatting if supported
              if capabilities.documentFormattingProvider then
                vim.keymap.set('n', '<leader>w', function() vim.lsp.buf.format { async = true } end, { desc = 'Format Buffer', ${opts} })
              end
              -- Other keybinds
              vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = '[G]o to [D]efinition', ${opts} })
              vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { desc = '[G]o to [T]ype Definition', ${opts} })
              vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = '[G]o to [I]mplementation', ${opts} })
            end
          '';
        };
    }
  ];
}
