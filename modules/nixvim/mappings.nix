{
  lib,
  config,
  helpers,
  ...
}:
let
  inherit (helpers) mkRaw;
  cfg = config.jhome.nvim;
in
{
  config.keymaps = [
    # Quickfix
    {
      mode = "n";
      key = "<leader>qo";
      action = "<cmd>Copen<CR>";
      options.desc = "Quickfix Open";
    }
    {
      mode = "n";
      key = "<leader>qq";
      action = "<cmd>cclose<CR>";
      options.desc = "Quickfix Quit";
    }
    {
      mode = "n";
      key = "<leader>qj";
      action = "<cmd>cnext<CR>";
      options.desc = "Quickfix next [J]";
    }
    {
      mode = "n";
      key = "<leader>qk";
      action = "<cmd>cprev<CR>";
      options.desc = "Quickfix previous [K]";
    }
    # Open or create file
    {
      mode = "n";
      key = "<leader>gf";
      action = "<cmd>e <cfile><CR>";
      options.desc = "Go to File";
    }
    # Keep Selection when indenting
    {
      mode = "x";
      key = ">";
      action = ">gv";
      options.desc = "Indent Selection";
    }
    {
      mode = "x";
      key = "<";
      action = "<gv";
      options.desc = "Deindent Selection";
    }
    # Diagnostics
    {
      mode = "n";
      key = "<leader>dj";
      action =
        mkRaw
          # lua
          ''
            vim.diagnostic.goto_next
          '';
      options.desc = "Diagnostics next [J]";
    }
    {
      mode = "n";
      key = "<leader>dk";
      action =
        mkRaw
          # lua
          ''
            vim.diagnostic.goto_prev
          '';
      options.desc = "Diagnostics previous [K]";
    }
    {
      mode = "n";
      key = "<leader>xs";
      action =
        mkRaw
          # lua
          ''
            function() require('trouble').toggle_preview('symbols') end
          '';
      options.desc = "Toggle Diagnostics trouble";
    }
    {
      mode = "n";
      key = "<leader>xd";
      action =
        mkRaw
          # lua
          ''
            function() require('trouble').toggle_preview('diagnostics') end
          '';
      options.desc = "Toggle Diagnostics trouble";
    }
    {
      mode = "n";
      key = "<leader>xq";
      action =
        mkRaw
          # lua
          ''
            function() require('trouble').toggle_preview('quickfix') end
          '';
      options.desc = "Toggle Quickfix trouble";
    }
    {
      mode = "n";
      key = "<leader>xl";
      action =
        mkRaw
          # lua
          ''
            function() require('trouble').toggle_preview('loclist') end
          '';
      options.desc = "Toggle Loclist trouble";
    }
    {
      mode = "n";
      key = "gR";
      action =
        mkRaw
          # lua
          ''
            function() require('trouble').toggle_preview('lsp_references') end
          '';
      options.desc = "Toggle lsp References trouble";
    }
    # Telescope
    {
      mode = "n";
      key = "<leader>ff";
      action =
        mkRaw
          # lua
          ''
            require('telescope.builtin').find_files
          '';
      options.desc = "Find Files";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action =
        mkRaw
          # lua
          ''
            require('telescope.builtin').live_grep
          '';
      options.desc = "Find Grep";
    }
    {
      mode = "n";
      key = "<leader>fh";
      action =
        mkRaw
          # lua
          ''
            require('telescope.builtin').help_tags
          '';
      options.desc = "Find Help";
    }
    {
      mode = "n";
      key = "<leader>fb";
      action =
        mkRaw
          # lua
          ''
            require('telescope.builtin').buffers
          '';
      options.desc = "Find Buffer";
    }
    {
      mode = "n";
      key = "<leader>fd";
      action =
        mkRaw
          # lua
          ''
            require('telescope.builtin').diagnostics
          '';
      options.desc = "Find Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>fq";
      action =
        mkRaw
          # lua
          ''
            require('telescope.builtin').quickfix
          '';
      options.desc = "Find Quickfix";
    }
  ]
  # Nvim Silicon
  ++ lib.optional (!cfg.reduceSize) {
    mode = "v";
    key = "<leader>sc";
    action =
      mkRaw
        # lua
        ''
          require('nvim-silicon').clip

        '';
    options.desc = "Snap Code (to clipboard)";
  }
  ++ lib.optional cfg.dev.enable {
    mode = "n";
    key = "<leader>w";
    action =
      mkRaw
        # lua
        ''
          require('conform').format
        '';
    options.desc = "Format buffer";
  };
}
