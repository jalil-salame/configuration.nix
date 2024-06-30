# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{nixos-hardware}: {pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-pc
    nixos-hardware.nixosModules.common-pc-ssd
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-gpu-amd
  ];
  fileSystems = {
    "/".options = ["compress=zstd"];
    "/steam".options = ["compress=zstd"];
    "/home".options = ["compress=zstd"];
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
  };
  boot.loader = {
    systemd-boot = {
      # Use the systemd-boot EFI boot loader.
      enable = true;
      configurationLimit = 3;
    };
    efi.canTouchEfiVariables = true;
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  networking = {
    hostName = "gemini";
    networkmanager.enable = true;
    interfaces.enp4s0.wakeOnLan.enable = true;
  };

  console = {
    # font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };
  services.openssh = {
    # Configure keymap in X11
    # services.xserver.xkbOptions = {
    #   "caps:swapescape" # map caps to escape.
    # };
    enable = true;
    startWhenNeeded = true;
    settings.AllowUsers = ["jalil"];
  };

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
