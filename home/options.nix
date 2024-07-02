{
  lib,
  pkgs,
  ...
} @ attrs: let
  osConfig = attrs.osConfig or null;
  inherit (lib) types;
  fromOs = let
    get = path: set:
      if path == []
      then set
      else get (builtins.tail path) (builtins.getAttr (builtins.head path) set);
  in
    path: default:
      if osConfig == null
      then default
      else get path osConfig;
  fromConfig = path: default: fromOs (["jconfig"] ++ path) default;

  mkExtraPackagesOption = name: defaultPkgsPath: let
    text =
      lib.strings.concatMapStringsSep " " (
        pkgPath: "pkgs." + (lib.strings.concatStringsSep "." pkgPath)
      )
      defaultPkgsPath;
    defaultText = lib.literalExpression "[ ${text} ]";
    default = builtins.map (pkgPath: lib.attrsets.getAttrFromPath pkgPath pkgs) defaultPkgsPath;
  in
    lib.mkOption {
      description = "Extra ${name} Packages.";
      type = types.listOf types.package;
      inherit default defaultText;
      example = [];
    };

  identity.options = {
    email = lib.mkOption {
      description = "Primary email address";
      type = types.str;
      example = "email@example.org";
    };
    name = lib.mkOption {
      description = "The default name you use.";
      type = types.str;
      example = "John Doe";
    };
    signingKey = lib.mkOption {
      description = "The signing key programs should use (i.e. git).";
      type = types.nullOr types.str;
      default = null;
      example = "F016B9E770737A0B";
    };
    encryptionKey = lib.mkOption {
      description = "The encryption key programs should use (i.e. pass).";
      type = types.nullOr types.str;
      default = null;
      example = "F016B9E770737A0B";
    };
  };

  user.options = {
    enable = lib.mkEnableOption "Jalil's default user configuration";
    gpg = lib.mkOption {
      description = "GnuPG Configuration.";
      default = {};
      type = types.submodule {
        options.unlockKeys = lib.mkOption {
          description = "Keygrips of keys to unlock through `pam-gnupg` when logging in.";
          default = [];
          example = ["6F4ABB77A88E922406BCE6627AFEEE2363914B76"];
          type = types.listOf types.str;
        };
      };
    };
    defaultIdentity = lib.mkOption {
      description = "The default identity to use in things like git.";
      type = types.submodule identity;
    };
  };

  tempInfo.options.hwmon-path = lib.mkOption {
    description = "Path to the hardware sensor whose temperature to monitor.";
    type = types.str;
    example = "/sys/class/hwmon/hwmon2/temp1_input";
  };

  sway.options = {
    enable = lib.mkEnableOption "sway" // {default = fromConfig ["gui" "sway"] true;};
    background = lib.mkOption {
      description = "The wallpaper to use.";
      type = types.path;
      default = fromConfig ["styling" "wallpaper"] (builtins.fetchurl {
        url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/d4937c424fad79c1136a904599ba689fcf8d0fad/png/gruvbox-dark-rainbow.png";
        sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
      });
    };
    autostart = lib.mkOption {
      description = ''
        Autostart Sway when logging in to /dev/tty1.

        This will make it so `exec sway` is run when logging in to TTY1, if
        you want a non-graphical session (ie. your GPU drivers are broken)
        you can switch TTYs when logging in by using CTRL+ALT+F2 (for TTY2,
        F3 for TTY3, etc).
      '';
      type = types.bool;
      default = true;
      example = false;
    };
    exec = lib.mkOption {
      description = "Run commands when starting sway.";
      default = {};
      type = types.submodule {
        options = {
          once = lib.mkOption {
            description = "Programs to start only once (`exec`).";
            type = types.listOf types.str;
            default = [];
            example = ["signal-desktop --start-in-tray"];
          };
          always = lib.mkOption {
            description = "Programs to start whenever the config is sourced (`exec_always`).";
            type = types.listOf types.str;
            default = [];
            example = ["signal-desktop --start-in-tray"];
          };
        };
      };
    };
  };

  gui.options = {
    enable = lib.mkEnableOption "GUI applications" // {default = fromConfig ["gui" "enable"] false;};
    tempInfo = lib.mkOption {
      description = "Temperature info to display in the statusbar.";
      default = null;
      type = types.nullOr (types.submodule tempInfo);
    };
    sway = lib.mkOption {
      description = "Sway window manager configuration.";
      default = {};
      type = types.submodule sway;
    };
    terminal = lib.mkOption {
      description = "The terminal emulator to use.";
      default = "wezterm";
      example = "alacritty";
      type = types.enum [
        "wezterm"
        "alacritty"
      ];
    };
  };
in {
  options.jhome = lib.mkOption {
    description = "Jalil's default home-manager configuration.";
    default = {};
    type = types.submodule {
      options = {
        enable = lib.mkEnableOption "jalil's home defaults";
        hostName = lib.mkOption {
          description = "The hostname of this system.";
          type = types.str;
          default = fromOs ["networking" "hostName"] "nixos";
          example = "my pc";
        };
        dev = lib.mkOption {
          description = "Setup development environment for programming languages.";
          default = {};
          type = types.submodule {
            options = {
              enable = lib.mkEnableOption "development settings" // {default = fromConfig ["dev" "enable"] false;};
              neovimAsManPager = lib.mkEnableOption "neovim as the man pager";
              extraPackages = mkExtraPackagesOption "dev" [
                ["jq"] # json parser
                ["just"] # just a command runner
                ["typos"] # low false positive rate typo checker
                ["gcc"] # GNU Compiler Collection
                ["git-absorb"] # fixup! but automatic
                ["man-pages"] # gimme the man pages
                ["man-pages-posix"] # I said gimme the man pages!!!
              ];
              rust = lib.mkOption {
                description = "Jalil's default rust configuration.";
                default = {};
                type = types.submodule {
                  options.enable = lib.mkEnableOption "rust development settings";
                  options.extraPackages = mkExtraPackagesOption "Rust" [
                    ["cargo-insta"] # snapshot testing
                    ["cargo-llvm-cov"] # code coverage
                    ["cargo-msrv"] # minimum supported version
                    ["cargo-nextest"] # better testing harness
                    ["cargo-sort"] # sort deps and imports
                    ["cargo-udeps"] # check for unused dependencies (requires nightly)
                    ["cargo-watch"] # watch for file changes and run commands
                  ];
                };
              };
            };
          };
        };
        user = lib.mkOption {
          description = "User settings.";
          default = null;
          type = types.nullOr (types.submodule user);
        };
        gui = lib.mkOption {
          description = "Jalil's default GUI configuration.";
          default = {};
          type = types.submodule gui;
        };
        styling = lib.mkOption {
          description = "My custom styling (uses stylix)";
          default = {};
          type = types.submodule {
            options = {
              enable = lib.mkEnableOption "styling" // {default = fromConfig ["styling" "enable"] true;};
            };
          };
        };
      };
    };
  };
}
