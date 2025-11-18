{ pkgs, lib, ... }@args:
let
  cfg = args.config.jconfig;
  keysFromGithub = lib.attrsets.mapAttrs' (username: sha256: {
    name = "pubkeys/${username}";
    value = {
      mode = "0755";
      source = pkgs.fetchurl {
        inherit sha256;
        url = "https://github.com/${username}.keys";
      };
    };
  }) cfg.importSSHKeysFromGithub;
in
{
  imports = [
    ./options.nix
    ./dev.nix
    ./gui.nix
    ./styling.nix
    (import ../shared/starship.nix { inherit cfg; })
  ];

  config = lib.mkIf cfg.enable {
    # Enable unlocking the gpg-agent at boot (configured through home.nix)
    security.pam.services.login.gnupg.enable = true;

    # Disable NixOS documentation (uses nix instead of lix)
    documentation.nixos.enable = lib.mkDefault false;

    environment.systemPackages = [
      # CLI tools
      pkgs.fd
      pkgs.ripgrep
      pkgs.du-dust
      pkgs.curl
      pkgs.zip
      pkgs.unzip
    ];

    programs.fish.enable = true;

    environment.etc = keysFromGithub;
    services = {
      # Enable printer autodiscovery if printing is enabled
      avahi = {
        inherit (args.config.services.printing) enable;
        nssmdns4 = true;
        openFirewall = true;
      };
      openssh.authorizedKeysFiles = builtins.map (keys: "/etc/${keys}") (
        builtins.attrNames keysFromGithub
      );
    };
    # Open ports for spotifyd
    networking.firewall = {
      allowedUDPPorts = [ 5353 ];
      allowedTCPPorts = [ 2020 ];
    };
    # Nix Settings
    nix = {
      package = pkgs.lixPackageSets.latest.lix; # use lix
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
  };
}
