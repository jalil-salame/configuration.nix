{ lib, ... }:
let
  inherit (lib) types;

  identity.options = {
    email = lib.mkOption {
      description = "Primary email adderss";
      type = types.str;
      example = "email@example.org";
    };
    name = lib.mkOption {
      description = "The default name you use.";
      type = types.str;
      example = "John Doe";
    };
    gpgKey = lib.mkOption {
      description = "The keygrip of your GPG key.";
      type = types.nullOr types.str;
      default = null;
      example = "6F4ABB77A88E922406BCE6627AFEEE2363914B76";
    };
  };

  user.options = {
    enable = lib.mkEnableOption "Jalil's default user configuration";
    unlockGpgKeyOnLogin = lib.mkEnableOption "unlocking the gpg key on login";
    defaultIdentity = lib.mkOption {
      description = "The default identity to use in things like git.";
      type = types.submodule identity;
    };
  };

  tempInfo.options.hwmon-path = lib.mkOption {
    description = "Path to the hardware sensor whose temperature to monitor.";
    type = lib.types.str;
    example = "/sys/class/hwmon/hwmon2/temp1_input";
  };

  sway.options = {
    background = lib.mkOption {
      description = lib.mdDoc "The wallpaper to use.";
      type = lib.types.path;
      default = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/d4937c424fad79c1136a904599ba689fcf8d0fad/png/gruvbox-dark-rainbow.png";
        sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
      };
    };
    autostart = lib.mkOption {
      description = lib.mdDoc ''
        Autostart Sway when logging in to /dev/tty1.

        This will make it so `exec sway` is run when logging in to TTY1, if
        you want a non-graphical session (ie. your GPU drivers are broken)
        you can switch TTYs when logging in by using CTRL+ALT+F2 (for TTY2,
        F3 for TTY3, etc).
      '';
      type = lib.types.bool;
      default = true;
      example = false;
    };
    exec = lib.mkOption {
      description = "Run commands when starting sway.";
      default = { };
      type = lib.types.submodule {
        options = {
          once = lib.mkOption {
            description = lib.mdDoc "Programs to start only once (`exec`).";
            type = lib.types.listOf lib.types.str;
            default = [ ];
            example = [ "signal-desktop --start-in-tray" ];
          };
          always = lib.mkOption {
            description = lib.mdDoc "Programs to start whenever the config is sourced (`exec_always`).";
            type = lib.types.listOf lib.types.str;
            default = [ ];
            example = [ "signal-desktop --start-in-tray" ];
          };
        };
      };
    };
  };

  gui.options = {
    enable = lib.mkEnableOption ("GUI applications");
    tempInfo = lib.mkOption {
      description = lib.mdDoc "Temperature info to display in the statusbar.";
      default = null;
      type = lib.types.nullOr (lib.types.submodule tempInfo);
    };
    sway = lib.mkOption {
      description = "Sway window manager configuration.";
      default = { };
      type = lib.types.submodule sway;
    };
  };
in
{
  options.jhome = lib.mkOption {
    description = lib.mdDoc "Jalil's default home-manager configuration.";
    default = { };
    type = types.submodule {
      options = {
        enable = lib.mkEnableOption "jalil's home defaults";
        hostName = lib.mkOption {
          description = lib.mdDoc "The hostname of this system.";
          type = types.str;
          default = "nixos";
          example = "my pc";
        };
        dev = lib.mkOption {
          description = lib.mdDoc "Setup development environment for programming languages.";
          default = { };
          type = types.submodule {
            options.rust = lib.mkOption {
              description = "Jalil's default rust configuration.";
              default = { };
              type = types.submodule {
                options.enable = lib.mkEnableOption "rust dev environment";
              };
            };
          };
        };
        user = lib.mkOption {
          description = lib.mdDoc "User settings.";
          default = null;
          type = types.nullOr (types.submodule user);
        };
        gui = lib.mkOption {
          description = lib.mdDoc "Jalil's default GUI configuration.";
          default = { };
          type = lib.types.submodule gui;
        };
      };
    };
  };
}
