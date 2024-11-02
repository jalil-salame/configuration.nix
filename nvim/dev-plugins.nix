{
  lib,
  pkgs,
  config,
  helpers,
  ...
}:
let
  inherit (helpers) enableExceptInTests;
  cfg = config.jhome.nvim;
  enabledLSPs = [
    "bashls"
    # "clangd" # Adds ~2GiB
    # "html" # Not writing html
    "jsonls"
    "marksman"
    "nixd"
    "pyright"
    "ruff"
    "taplo"
    # "texlab" # Not using it
    "typos_lsp"
    # "typst_lsp" # Not using it
  ];
in
{
  config = lib.mkIf cfg.dev.enable (
    lib.mkMerge [
      # Enable LSPs
      {
        plugins.lsp.servers = lib.genAttrs enabledLSPs (_: {
          enable = true;
        });
      }
      # Remove bundled LSPs
      (lib.mkIf (!cfg.dev.bundleLSPs) {
        plugins.lsp.servers = lib.genAttrs enabledLSPs (_: {
          package = null;
        });
      })
      # Configure LSPs
      {
        plugins = {
          lsp.servers.bashls.package = pkgs.bash-language-server;
          lspkind = {
            enable = true;
            mode = "symbol";
            extraOptions.maxwidth = 50;
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
      # Configure Formatters
      {
        extraPackages = [
          pkgs.luajitPackages.jsregexp
          pkgs.shfmt
          pkgs.stylua
          pkgs.taplo
          pkgs.yamlfmt
        ];
        plugins.conform-nvim = {
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
      }
      # Configure Linters
      {
        extraPackages = [
          pkgs.dash
          pkgs.statix
          pkgs.zsh
        ];
        plugins.lint = {
          enable = true;
          lintersByFt = {
            # latex = [ "chktex" ]; # Not in use
            nix = [ "statix" ];
            sh = [ "dash" ];
            zsh = [ "zsh" ];
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
        };
      }
      # Rust plugins
      {
        plugins = {
          bacon = {
            enable = true;
            settings.quickfix.enabled = true;
          };
          rustaceanvim = {
            enable = true;
            # Install through rustup
            rustAnalyzerPackage = null;
          };
        };
      }
      # Other plugins
      {
        plugins = {
          nvim-colorizer = {
            enable = true;
            userDefaultOptions = {
              names = false; # disable named colors (i.e. red)
              mode = "virtualtext";
            };
          };
          otter.enable = true;
        };
      }
    ]
  );
}
