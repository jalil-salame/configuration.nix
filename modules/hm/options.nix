{ lib, pkgs, ... }@attrs:
let
  jalilLib = import ../lib.nix { inherit lib; };
  fromOsOptions = jalilLib.fromOsOptions attrs;
  inherit (jalilLib)
    mkDisableOption
    mkExtraPackagesOption'
    ;

  inherit (fromOsOptions)
    mkFromOsOption
    mkFromConfigOption
    mkFromConfigImageOption
    mkFromConfigEnableOption
    mkFromConfigDisableOption
    ;

  mkExtraPackagesOption = mkExtraPackagesOption' pkgs;

  inherit (lib) types;

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
      default = { };
      type = types.submodule {
        options.unlockKeys = lib.mkOption {
          description = "Keygrips of keys to unlock through `pam-gnupg` when logging in.";
          default = [ ];
          example = [ "6F4ABB77A88E922406BCE6627AFEEE2363914B76" ];
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
    enable = mkFromConfigDisableOption "Enable sway" [
      "gui"
      "sway"
    ];
    exec = lib.mkOption {
      description = "Run commands when starting sway.";
      default = { };
      type = types.submodule {
        options = {
          once = lib.mkOption {
            description = "Programs to start only once (`exec`).";
            type = types.listOf types.str;
            default = [ ];
            example = [ "signal-desktop --start-in-tray" ];
          };
          always = lib.mkOption {
            description = "Programs to start whenever the config is sourced (`exec_always`).";
            type = types.listOf types.str;
            default = [ ];
            example = [ "signal-desktop --start-in-tray" ];
          };
        };
      };
    };
  };

  gui.options = {
    enable = mkFromConfigEnableOption "GUI applications" [
      "gui"
      "enable"
    ];
    wallpaper = mkFromConfigImageOption {
      description = "The wallpaper to use.";
      path = [
        "styling"
        "wallpaper"
      ];
      url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/d4937c424fad79c1136a904599ba689fcf8d0fad/png/gruvbox-dark-rainbow.png";
      sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
    };
    autostartWindowManager = lib.mkOption {
      description = ''
        Autostart a configured window manager when logging in to /dev/tty1. Set
        to `"none"` to disable.

        This will make it so `exec $windowManager` is run when logging in to
        TTY1, if you want a non-graphical session (ie. your GPU drivers are
        broken) you can switch TTYs when logging in by using CTRL+ALT+F2 (for
        TTY2, F3 for TTY3, etc).
      '';
      type = types.enum [
        "sway"
        "none"
      ];
      default = "sway";
      example = "none";
    };
    tempInfo = lib.mkOption {
      description = "Temperature info to display in the statusbar.";
      default = null;
      type = types.nullOr (types.submodule tempInfo);
    };
    sway = lib.mkOption {
      description = "Sway window manager configuration.";
      default = { };
      type = types.submodule sway;
    };
    terminal = lib.mkOption {
      description = "The terminal emulator to use.";
      default = "alacritty";
      example = "wezterm";
      type = types.enum [
        "wezterm"
        "alacritty"
      ];
    };
  };
in
{
  # add fromOs function to args
  config._module.args = { inherit (fromOsOptions) fromOs; };

  options.jhome = lib.mkOption {
    description = "Jalil's default home-manager configuration.";
    default = { };
    type = types.submodule {
      options = {
        enable = lib.mkEnableOption "jalil's home defaults";
        hostName = mkFromOsOption {
          description = "The hostname of this system.";
          type = types.str;
          path = [
            "networking"
            "hostName"
          ];
          default = "nixos";
          example = "my-cool-pc-name";
        };
        dev = lib.mkOption {
          description = "Setup development environment for programming languages.";
          default = { };
          type = types.submodule {
            options = {
              enable = mkFromConfigEnableOption "development settings" [
                "dev"
                "enable"
              ];
              neovimAsManPager = lib.mkEnableOption "neovim as the man pager";
              extraPackages = mkExtraPackagesOption "dev" [
                # FIXME: readd on new lix version with fix [ "devenv" ] # a devshell alternative
                [ "jq" ] # json parser
                [ "just" ] # just a command runner
                [ "typos" ] # low false positive rate typo checker
                [ "gcc" ] # GNU Compiler Collection
                [ "man-pages" ] # gimme the man pages
                [ "man-pages-posix" ] # I said gimme the man pages!!!
              ];
              rust = lib.mkOption {
                description = "Jalil's default rust configuration.";
                default = { };
                type = types.submodule {
                  options.enable = lib.mkEnableOption "rust development settings";
                  options.extraPackages = mkExtraPackagesOption "Rust" [
                    [ "cargo-insta" ] # snapshot testing
                    [ "cargo-nextest" ] # better testing harness
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
          default = { };
          type = types.submodule gui;
        };
        styling = lib.mkOption {
          description = "My custom styling (uses stylix)";
          default = { };
          type = types.submodule {
            options.enable = mkFromConfigEnableOption "styling" [
              "styling"
              "enable"
            ];
          };
        };
      };
    };
  };
}
