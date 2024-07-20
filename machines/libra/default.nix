# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ nixos-hardware }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.tuxedo-pulse-14-gen3
  ];

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
  };
  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      timeout = 0; # Press Space to show the menu
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
    };
  };
  # Fixes graphical issues
  hardware = {
    opengl.enable = true;
    bluetooth.enable = true;
    # tuxedo-rs = {
    #   enable = true;
    #   tailor-gui.enable = true;
    # };
  };
  networking = {
    hostName = "libra";
    networkmanager = {
      enable = true; # Easiest to use and most distros use this by default.
      # networking.networkmanager.wifi.backend = "iwd"; # Seems to cause problems
      appendNameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
        "8.4.4.8"
      ];
    };
  };

  # use xkb.options in tty.
  console.useXkbConfig = true;
  services = {
    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
