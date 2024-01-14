{ stylix }: { config, pkgs, lib, ... }:
let
  inherit (lib) types;
  cfg = config.jconfig;
  mkDisableOption = option: lib.mkOption {
    description = lib.mdDoc "Whether to enable ${option}.";
    type = types.bool;
    default = true;
    example = false;
  };
in
{
  imports = [ ./gui ] ++ lib.optional (cfg.enable && cfg.styling.enable) stylix.homeManagerModules.stylix;

  options.jconfig = lib.mkOption {
    description = lib.mdDoc "Jalil's default NixOS configuration.";
    type = types.submodule {
      options.enable = lib.mkEnableOption "jalil's default configuration.";
      options.styling = lib.mkOption {
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

  config = lib.optionalAttrs cfg.enable {
    boot.plymouth.enable = cfg.styling.enable;
    stylix = lib.optionalAttrs cfg.styling.enable (import ./stylix-config.nix);

    # Enable unlocking the gpg-agent at boot (configured through home.nix)
    security.pam.services.login.gnupg.enable = true;

    environment.systemPackages = [
      # Dev tools
      pkgs.gcc
      pkgs.just
      pkgs.clang
      # CLI tools
      pkgs.fd
      pkgs.bat
      pkgs.skim
      pkgs.ripgrep
      pkgs.du-dust
      pkgs.curl
      pkgs.wget
      pkgs.eza
    ];

    # Shell prompt
    programs.starship.enable = true;
    programs.starship.settings = lib.optionalAttrs cfg.styling.enable {
      format = "$time$all";
      add_newline = false;
      cmd_duration.min_time = 500;
      cmd_duration.show_milliseconds = true;
      time.format = "[$time](bold yellow) ";
      time.disabled = false;
      status.format = "[$signal_name$common_meaning$maybe_int](red)";
      status.symbol = "[✗](bold red)";
      status.disabled = false;
      sudo.disabled = false;
    };
    # Default shell
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;

    # Open ports for spotifyd
    networking.firewall.allowedUDPPorts = [ 5353 ];
    networking.firewall.allowedTCPPorts = [ 2020 ];

    # Nix Settings
    nix.gc.automatic = true;
    nix.gc.dates = "weekly";
    nix.gc.options = "--delete-older-than 30d";
    # run between 0 and 45min after boot if run was missed
    nix.gc.randomizedDelaySec = "45min";
    nix.settings.auto-optimise-store = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
