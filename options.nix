{ lib, ... }:
let
  inherit (lib) types;
  # Like mkEnableOption but defaults to true
  mkDisableOption = option: lib.mkOption {
    description = lib.mdDoc "Whether to enable ${option}.";
    type = types.bool;
    default = true;
    example = false;
  };
in
{
  options.jconfig = lib.mkOption {
    description = lib.mdDoc "Jalil's default NixOS configuration.";
    type = types.submodule {
      options = {
        enable = lib.mkEnableOption "jalil's default configuration.";
        gui = lib.mkOption {
          description = lib.mdDoc "Jalil's default configuration for a NixOS gui.";
          type = types.submodule {
            options.enable = lib.mkEnableOption "jalil's default gui configuration.";
            # Fix for using Xinput mode on 8bitdo Ultimate C controller
            # Inspired by https://aur.archlinux.org/packages/8bitdo-ultimate-controller-udev
            # Adapted from: https://gist.github.com/interdependence/28452fbfbe692986934fbe1e54c920d4
            options."8bitdoFix" = mkDisableOption "a fix for 8bitdo controllers";
            options.steamHardwareSupport = mkDisableOption "steam hardware support";
            options.ydotool = lib.mkOption {
              description = lib.mdDoc "Jalil's default ydotool configuration.";
              type = types.submodule {
                options.enable = mkDisableOption "ydotool";
                options.autoStart = mkDisableOption "autostarting ydotool at login";
              };
            };
          };
        };
        styling = lib.mkOption {
          description = "Jalil's styling options";
          type = types.submodule {
            options.enable = mkDisableOption "jalil's default styling";
            options.wallpaper = lib.mkOption {
              description = "The wallpaper to use.";
              type = types.str;
              default = builtins.fetchurl {
                url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/d4937c424fad79c1136a904599ba689fcf8d0fad/png/gruvbox-dark-rainbow.png";
                sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
              };
            };
            options.bootLogo = lib.mkOption {
              description = "The logo used by plymouth at boot.";
              type = types.str;
              # http://xenia-linux-site.glitch.me/images/cathodegaytube-splash.png
              default = builtins.fetchurl {
                url = "https://efimero.github.io/xenia-images/cathodegaytube-splash.png";
                sha256 = "qKugUfdRNvMwSNah+YmMepY3Nj6mWlKFh7jlGlAQDo8=";
              };
            };
          };
        };
      };
    };
  };
}
