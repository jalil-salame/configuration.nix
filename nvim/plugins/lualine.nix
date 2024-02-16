{
  enable = true;
  theme = "gruvbox";
  sections = {
    lualine_a = [ "mode" ];
    lualine_b = [ "filename" "branch" ];
    lualine_c = [
      {
        lsp_progress = {
          separators = {
            component = " ";
            progress = " | ";
            percentage = {
              pre = "";
              post = "%% ";
            };
            title = {
              pre = "";
              post = ": ";
            };
            lsp_client_name = {
              pre = "[";
              post = "]";
            };
            spinner = {
              pre = "";
              post = "";
            };
            message = {
              pre = "(";
              post = ")";
              commenced = "In Progress";
              completed = "Completed";
            };
          };
          display_components = [ "lsp_client_name" "spinner" "title" "percentage" "message" ];
          timer = {
            progress_enddelay = 500;
            spinner = 1000;
            lsp_client_name_enddelay = 1000;
          };
          spinner_symbols = [ "🌑 " "🌒 " "🌓 " "🌔 " "🌕 " "🌖 " "🌗 " "🌘 " ];
        };
      }
    ];
    lualine_x = [ ];
    lualine_y = [ "encoding" "fileformat" "filetype" ];
    lualine_z = [ "location" ];
  };
}
