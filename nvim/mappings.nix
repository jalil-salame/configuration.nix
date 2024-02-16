{
  # Quickfix
  normal."<leader>qo" = {
    action = "'<cmd>Copen<CR>'";
    desc = "Quickfix Open";
  };
  normal."<leader>qq" = {
    action = "'<cmd>cclose<CR>'";
    desc = "Quickfix Quit";
  };
  normal."<leader>qj" = {
    action = "'<cmd>cnext<CR>'";
    desc = "Quickfix next [J]";
  };
  normal."<leader>qk" = {
    action = "'<cmd>cprev<CR>'";
    desc = "Quickfix previous [K]";
  };
  # Open or create file
  normal."<leader>gf" = {
    action = "'<cmd>e <cfile><CR>'";
    desc = "Go to File";
  };
  # Keep Selection when indenting
  visualOnly.">" = {
    action = "'>gv'";
    desc = "Indent Selection";
  };
  visualOnly."<" = {
    action = "'<gv'";
    desc = "Deindent Selection";
  };
  # Diagnostics
  normal."<leader>dj" = {
    action = "vim.diagnostic.goto_next";
    desc = "Diagnostics next [J]";
  };
  normal."<leader>dk" = {
    action = "vim.diagnostic.goto_prev";
    desc = "Diagnostics previous [K]";
  };
  normal."<leader>xx" = {
    action = "require('trouble').toggle";
    desc = "Toggle trouble";
  };
  normal."<leader>xw" = {
    action = "function() require('trouble').toggle('workspace_diagnostics') end";
    desc = "Toggle Workspace trouble";
  };
  normal."<leader>xd" = {
    action = "function() require('trouble').toggle('document_diagnostics') end";
    desc = "Toggle Document trouble";
  };
  normal."<leader>xq" = {
    action = "function() require('trouble').toggle('quickfix') end";
    desc = "Toggle Quickfix trouble";
  };
  normal."<leader>xl" = {
    action = "function() require('trouble').toggle('loclist') end";
    desc = "Toggle Loclist trouble";
  };
  normal."gR" = {
    action = "function() require('trouble').toggle('lsp_references') end";
    desc = "Toggle lsp References trouble";
  };
  # Telescope
  normal."<leader>ff" = {
    action = "require('telescope.builtin').find_files";
    desc = "Find Files";
  };
  normal."<leader>fg" = {
    action = "require('telescope.builtin').live_grep";
    desc = "Find Grep";
  };
  normal."<leader>fh" = {
    action = "require('telescope.builtin').help_tags";
    desc = "Find Help";
  };
  normal."<leader>fb" = {
    action = "require('telescope.builtin').buffers";
    desc = "Find Buffer";
  };
  normal."<leader>fd" = {
    action = "require('telescope.builtin').diagnostics";
    desc = "Find Diagnostics";
  };
  normal."<leader>fq" = {
    action = "require('telescope.builtin').quickfix";
    desc = "Find Quickfix";
  };
}
