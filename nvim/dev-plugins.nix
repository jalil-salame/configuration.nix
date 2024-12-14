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
    "basedpyright"
    "bashls"
    "clangd"
    # "html" # Not writing html
    "jsonls"
    "marksman"
    "nixd"
    "ruff"
    "taplo"
    # "texlab" # Not using it
    "typos_lsp"
    # "typst_lsp" # Not using it
    "zls"
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
          lsp = {
            enable = true;
            servers = {
              # Pyright needs to have the project root set?
              basedpyright.rootDir = # lua
                ''
                  function()
                    return vim.fs.root(0, {'flake.nix', '.git', '.jj', 'pyproject.toml', 'setup.py'})
                  end
                '';
              bashls.package = lib.mkDefault pkgs.bash-language-server;
              # Adds ~2 GiB, install in a devShell instead
              clangd.package = lib.mkDefault null;
              # zls & other zig tools are big, install in a devShell instead
              zls.package = lib.mkDefault null;
            };
          };
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
      # Remove tools for building gramars when bundling them
      (lib.mkIf cfg.dev.bundleGrammars {
        plugins.treesitter = {
          gccPackage = null;
          nodejsPackage = null;
          treesitterPackage = null;
        };
      })
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
          colorizer = {
            enable = true;
            settings.user_default_options = {
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
