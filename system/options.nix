{lib, ...}: let
  inherit (lib) types;
  # Like mkEnableOption but defaults to true
  mkDisableOption = option:
    (lib.mkEnableOption option)
    // {
      default = true;
      example = false;
    };
  mkImageOption = {
    description,
    url,
    sha256 ? "",
  }:
    lib.mkOption {
      inherit description;
      type = types.path;
      default = builtins.fetchurl {inherit url sha256;};
      defaultText = lib.literalMD "![${description}](${url})";
    };

  gui.options = {
    enable = lib.mkEnableOption "jalil's default gui configuration.";
    # Fix for using Xinput mode on 8bitdo Ultimate C controller
    # Inspired by https://aur.archlinux.org/packages/8bitdo-ultimate-controller-udev
    # Adapted from: https://gist.github.com/interdependence/28452fbfbe692986934fbe1e54c920d4
    "8bitdoFix" = mkDisableOption "a fix for 8bitdo controllers";
    steamHardwareSupport = mkDisableOption "steam hardware support";
    ydotool = lib.mkOption {
      description = "Jalil's default ydotool configuration.";
      default = {};
      type = types.submodule {
        options.enable = mkDisableOption "ydotool";
        options.autoStart = mkDisableOption "autostarting ydotool at login";
      };
    };
    sway = mkDisableOption "sway";
  };

  styling.options = {
    enable = mkDisableOption "jalil's default styling (cannot be disabled currently)";
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

  config.options = {
    enable = lib.mkEnableOption "jalil's default configuration.";
    dev = lib.mkOption {
      description = "Options for setting up a dev environment";
      default = {};
      type = types.submodule {options.enable = lib.mkEnableOption "dev configuration";};
    };
    gui = lib.mkOption {
      description = "Jalil's default configuration for a NixOS gui.";
      default = {};
      type = types.submodule gui;
    };
    styling = lib.mkOption {
      description = "Jalil's styling options";
      default = {};
      type = types.submodule styling;
    };
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
      default = {};
      example = {
        "jalil-salame" = "sha256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
      };
      type = types.attrsOf types.str;
    };
  };
in {
  options.jconfig = lib.mkOption {
    description = "Jalil's default NixOS configuration.";
    default = {};
    type = types.submodule config;
  };
}
