{ pkgs, lib, ... }:
let
  inherit (lib) types;
  inherit (import ../lib.nix { inherit lib; })
    mkDisableOption
    mkImageOption'
    ;

  mkImageOption = mkImageOption' pkgs;
in
{
  options.jconfig = lib.mkOption {
    description = "Jalil's default NixOS configuration.";
    default = { };
    type = types.submodule {
      options = {
        enable = lib.mkEnableOption "jalil's default configuration.";
        importSSHKeysFromGithub = lib.mkOption {
          description = ''
            Import public ssh keys from a github username.

            This will fetch the keys from https://github.com/$${username}.keys.

            The format is `"$${github-username}" = $${sha256-hash}`. The example
            will try to fetch the keys from <https://github.com/jalil-salame.keys>.

            **Warning**: this will interfere with services like gitea that override
            the default ssh behaviour. In that case you want to use
            `users.users.<name>.openssh.authorizedKeys.keyFiles` on the users you
            want to allow ssh logins.
          '';
          default = { };
          example = {
            "jalil-salame" = "sha256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
          };
          type = types.attrsOf types.str;
        };

        dev = lib.mkOption {
          description = "Options for setting up a dev environment";
          default = { };
          type = types.submodule {
            options = {
              enable = lib.mkEnableOption "dev configuration";
              jupyter.enable = lib.mkEnableOption "jupyter configuration";
            };
          };
        };

        gui = lib.mkOption {
          description = "Jalil's default configuration for a NixOS gui.";
          default = { };
          type = types.submodule {
            options = {
              enable = lib.mkEnableOption "jalil's default gui configuration.";
              # Fix for using Xinput mode on 8bitdo Ultimate C controller
              # Inspired by https://aur.archlinux.org/packages/8bitdo-ultimate-controller-udev
              # Adapted from: https://gist.github.com/interdependence/28452fbfbe692986934fbe1e54c920d4
              "8bitdoFix" = mkDisableOption "a fix for 8bitdo controllers";
              steamHardwareSupport = mkDisableOption "steam hardware support";
              ydotool = lib.mkOption {
                description = "Jalil's default ydotool configuration.";
                default = { };
                type = types.submodule {
                  options.enable = mkDisableOption "ydotool";
                  options.autoStart = mkDisableOption "autostarting ydotool at login";
                };
              };
              sway = mkDisableOption "the sway window manager";
            };
          };
        };

        styling = lib.mkOption {
          description = "Jalil's styling options";
          default = { };
          type = types.submodule {
            options = {
              enable = mkDisableOption "jalil's default styling (disables stylix)";
              wallpaper = mkImageOption {
                description = "The wallpaper to use.";
                url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/d4937c424fad79c1136a904599ba689fcf8d0fad/png/gruvbox-dark-rainbow.png";
                sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
              };
              bootLogo = mkImageOption {
                description = "The logo used by plymouth at boot.";
                # http://xenia-linux-site.glitch.me/images/cathodegaytube-splash.png
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
