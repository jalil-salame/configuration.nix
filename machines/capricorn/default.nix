{ nixos-hardware }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-hdd
    nixos-hardware.nixosModules.common-pc-laptop-ssd
    nixos-hardware.nixosModules.common-cpu-intel
  ];

  # Setup extra filesystem options
  fileSystems."/".options = [ "compress=zstd" ];
  fileSystems."/home".options = [ "compress=zstd" ];
  fileSystems."/nix".options = [ "compress=zstd" "noatime" ];

  hardware.bluetooth.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Network configuration
  networking.hostName = "capricorn";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.networkmanager.appendNameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.4.4.8" ];

  console.useXkbConfig = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
