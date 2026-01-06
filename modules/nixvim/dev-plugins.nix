{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.nixvim) enableExceptInTests;
  inherit (lib.trivial) const;
  cfg = config.jhome.nvim;
  enabledLSPs = [
    "basedpyright"
    "bashls"
    "clangd"
    "gopls"
    "idris2_lsp"
    # "html" # Not writing html
    "jsonls"
    "lua_ls"
    "marksman"
    "ruff"
    "taplo"
    # "texlab" # Not using it
    "typos_lsp"
    # "typst_lsp" # Not using it
    "zls"
    "fish_lsp"
  ];

  enableOpt.enable = true;
  noPackage.package = null;
in
{
  config = lib.mkIf cfg.dev.enable (
    lib.mkMerge [
      # Enable LSPs
      { plugins.lsp.servers = lib.genAttrs enabledLSPs (const enableOpt); }
      # Remove bundled LSPs
      (lib.mkIf (!cfg.dev.bundleLSPs) {
        plugins.lsp.servers = lib.genAttrs enabledLSPs (const noPackage);
      })
      # Configure LSPs
      {
        plugins = {
          lsp = {
            enable = true;
            servers = {
              # Pyright needs to have the project root set?
              basedpyright.rootMarkers = [
                "flake.nix"
                ".git"
                ".jj"
                "pyproject.toml"
                "setup.py"
              ];
              # Big but infrequently used dependencies.
              #
              # Configure the LSPs, but don't install the packages.
              # If you need to use them, add them to your project's devShell
              clangd = noPackage;
              gopls = noPackage;
              zls = noPackage;
            };
          };
          lsp-lines.enable = true;
        };
      }
      # Configure Treesitter
      {
        plugins.treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
            incremental_election.enable = true;
          };
        };
      }
      # Do not bundle treesitter grammars
      (lib.mkIf (!cfg.dev.bundleGrammars) { plugins.treesitter.grammarPackages = [ ]; })
      # Remove tools for building gramars when bundling them
      (lib.mkIf cfg.dev.bundleGrammars {
        dependencies = {
          gcc.enable = false;
          nodejs.enable = false;
          tree-sitter.enable = false;
        };
      })
      # Configure Formatters
      {
        extraPackages = [ pkgs.luajitPackages.jsregexp ];
        plugins.conform-nvim = {
          enable = true;
          settings = {
            formatters = {
              fish.command = lib.getExe' pkgs.fish "fish_indent";
              nixfmt.command = lib.getExe pkgs.nixfmt-rfc-style;
              shfmt.command = lib.getExe pkgs.shfmt;
              stylua.command = lib.getExe pkgs.stylua;
              taplo.command = lib.getExe pkgs.taplo;
              yamlfmt.command = lib.getExe pkgs.yamlfmt;
            };
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
              fish = [ "fish_indent" ];
            };
          };
        };
      }
      # Configure Linters
      {
        plugins.lint = {
          enable = true;
          linters = {
            dash.command = lib.getExe pkgs.dash;
            statix.command = lib.getExe pkgs.statix;
            # chktex = lib.getExe pkgs.chktex; # Not in use
          };
          lintersByFt = {
            # latex = [ "chktex" ]; # Not in use
            nix = [ "statix" ];
            sh = [ "dash" ];
          };
        };
      }
      # Jupyter notebooks
      {
        extraPackages = [ (pkgs.python3.withPackages (p: [ p.jupytext ])) ];
        plugins = {
          image.enable = enableExceptInTests;
          jupytext = {
            enable = true;
            settings.custom_language_formatting.python = {
              extension = "md";
              style = "markdown";
              force_ft = "markdown";
            };
          };
          molten = {
            enable = true;
            settings = {
              image_provider = "image.nvim";
              virt_text_output = true;
              molten_auto_open_output = false;
              molten_virt_lines_off_by_1 = true;
            };
          };
        };
      }
      # Rust plugins
      {
        plugins.rustaceanvim.enable = true;
        # install through rustup
        dependencies.rust-analyzer.enable = false;
      }
      # Other plugins
      {
        plugins = {
          colorizer = {
            enable = true;
            settings.user_default_options = {
              names = false; # disable named colors (i.e. red)
              mode = "virtualtext";
            };
          };
          hunk.enable = true;
          otter.enable = true;
        };
      }
    ]
  );
}
