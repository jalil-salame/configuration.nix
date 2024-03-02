[
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
    action = "vim.diagnostic.goto_next";
    lua = true;
    options.desc = "Diagnostics next [J]";
  }
  {
    mode = "n";
    key = "<leader>dk";
    action = "vim.diagnostic.goto_prev";
    lua = true;
    options.desc = "Diagnostics previous [K]";
  }
  {
    mode = "n";
    key = "<leader>xx";
    action = "require('trouble').toggle";
    lua = true;
    options.desc = "Toggle trouble";
  }
  {
    mode = "n";
    key = "<leader>xw";
    action = "function() require('trouble').toggle('workspace_diagnostics') end";
    lua = true;
    options.desc = "Toggle Workspace trouble";
  }
  {
    mode = "n";
    key = "<leader>xd";
    action = "function() require('trouble').toggle('document_diagnostics') end";
    lua = true;
    options.desc = "Toggle Document trouble";
  }
  {
    mode = "n";
    key = "<leader>xq";
    action = "function() require('trouble').toggle('quickfix') end";
    lua = true;
    options.desc = "Toggle Quickfix trouble";
  }
  {
    mode = "n";
    key = "<leader>xl";
    action = "function() require('trouble').toggle('loclist') end";
    lua = true;
    options.desc = "Toggle Loclist trouble";
  }
  {
    mode = "n";
    key = "gR";
    action = "function() require('trouble').toggle('lsp_references') end";
    lua = true;
    options.desc = "Toggle lsp References trouble";
  }
  # Telescope
  {
    mode = "n";
    key = "<leader>ff";
    action = "require('telescope.builtin').find_files";
    lua = true;
    options.desc = "Find Files";
  }
  {
    mode = "n";
    key = "<leader>fg";
    action = "require('telescope.builtin').live_grep";
    lua = true;
    options.desc = "Find Grep";
  }
  {
    mode = "n";
    key = "<leader>fh";
    action = "require('telescope.builtin').help_tags";
    lua = true;
    options.desc = "Find Help";
  }
  {
    mode = "n";
    key = "<leader>fb";
    action = "require('telescope.builtin').buffers";
    lua = true;
    options.desc = "Find Buffer";
  }
  {
    mode = "n";
    key = "<leader>fd";
    action = "require('telescope.builtin').diagnostics";
    lua = true;
    options.desc = "Find Diagnostics";
  }
  {
    mode = "n";
    key = "<leader>fq";
    action = "require('telescope.builtin').quickfix";
    lua = true;
    options.desc = "Find Quickfix";
  }
]
