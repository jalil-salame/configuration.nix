{stylix}: {
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.jconfig;
  keysFromGithub =
    lib.attrsets.mapAttrs' (username: sha256: {
      name = "pubkeys/${username}";
      value = {
        mode = "0755";
        source = builtins.fetchurl {
          inherit sha256;
          url = "https://github.com/${username}.keys";
        };
      };
    })
    cfg.importSSHKeysFromGithub;
in {
  imports = [
    ./options.nix
    ./gui
    stylix.nixosModules.stylix
    # FIXME(https://github.com/danth/stylix/issues/216): Must configure stylix
    {stylix = import ./stylix-config.nix {inherit config pkgs;};}
  ];

  config = lib.mkIf cfg.enable {
    boot.plymouth.enable = cfg.styling.enable;

    # Enable unlocking the gpg-agent at boot (configured through home.nix)
    security.pam.services.login.gnupg.enable = true;

    environment.systemPackages = [
      # Dev tools
      pkgs.gcc
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
      pkgs.zip
      pkgs.unzip
    ];

    # Enable dev documentation
    documentation.dev.enable = cfg.dev.enable;
    programs = {
      # Shell prompt
      starship = {
        enable = true;
        settings = lib.mkIf cfg.styling.enable {
          format = "$time$all";
          add_newline = false;
          cmd_duration.min_time = 500;
          cmd_duration.show_milliseconds = true;
          time = {
            format = "[$time](bold yellow) ";
            disabled = false;
          };
          status = {
            format = "[$signal_name$common_meaning$maybe_int](red)";
            symbol = "[✗](bold red)";
            disabled = false;
          };
          sudo.disabled = false;
        };
      };
      # Default shell
      zsh.enable = true;
    };

    environment.etc = keysFromGithub;
    services.openssh.authorizedKeysFiles = builtins.map (path: "/etc/${path}") (
      builtins.attrNames keysFromGithub
    );

    # Enable printer autodiscovery if printing is enabled
    services.avahi = {
      inherit (config.services.printing) enable;
      nssmdns4 = true;
      openFirewall = true;
    };
    users.defaultUserShell = pkgs.zsh;
    # Open ports for spotifyd
    networking.firewall = {
      allowedUDPPorts = [5353];
      allowedTCPPorts = [2020];
    };
    # Nix Settings
    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
        # run between 0 and 45min after boot if run was missed
        randomizedDelaySec = "45min";
      };
      settings = {
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };
  };
}
