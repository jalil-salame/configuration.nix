{ stylix }:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.jconfig;
  keysFromGithub = lib.attrsets.mapAttrs' (username: sha256: {
    name = "pubkeys/${username}";
    value = {
      mode = "0755";
      source = builtins.fetchurl {
        inherit sha256;
        url = "https://github.com/${username}.keys";
      };
    };
  }) cfg.importSSHKeysFromGithub;
in
{
  imports = [
    ./options.nix
    ./gui
    stylix.nixosModules.stylix
    { stylix = import ./stylix-config.nix { inherit config pkgs; }; }
  ];

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        boot.plymouth = {
          inherit (cfg.styling) enable;
        };

        # Enable unlocking the gpg-agent at boot (configured through home.nix)
        security.pam.services.login.gnupg.enable = true;

        environment.systemPackages = [
          # CLI tools
          pkgs.fd
          pkgs.ripgrep
          pkgs.du-dust
          pkgs.curl
          pkgs.zip
          pkgs.unzip
        ];

        # Enable dev documentation
        documentation.dev = {
          inherit (cfg.dev) enable;
        };
        programs = {
          # Shell prompt
          starship = {
            enable = true;
            settings = {
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
        services = {
          # Enable printer autodiscovery if printing is enabled
          avahi = {
            inherit (config.services.printing) enable;
            nssmdns4 = true;
            openFirewall = true;
          };
          openssh.authorizedKeysFiles = builtins.map (path: "/etc/${path}") (
            builtins.attrNames keysFromGithub
          );
        };
        users.defaultUserShell = pkgs.zsh;
        # Open ports for spotifyd
        networking.firewall = {
          allowedUDPPorts = [ 5353 ];
          allowedTCPPorts = [ 2020 ];
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
            use-xdg-base-directories = true;
            auto-optimise-store = true;
            experimental-features = [
              "nix-command"
              "flakes"
            ];
          };
        };
      }
      # dev configuration
      (lib.mkIf cfg.dev.enable {
        users.extraUsers = lib.mkIf cfg.dev.jupyter.enable { jupyter.group = "jupyter"; };
        services.jupyter = {
          inherit (cfg.dev.jupyter) enable;
          group = "jupyter";
          user = "jupyter";
        };
      })
    ]
  );
}
