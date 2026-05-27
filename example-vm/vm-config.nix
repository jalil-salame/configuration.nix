## Default QEMU guest config
{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];

  services = {
    qemuGuest.enable = true;
    openssh.enable = true;
  };

  boot = {
    loader.systemd-boot.enable = true;
    initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "virtio_balloon"
      "virtio_blk"
      "virtio_pci"
      "virtio_ring"
      # "virtio_vga"
      "virtio_gpu"
    ];
  };
  # fileSystems."/".device = "/dev/disk/by-label/nixos";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

  nixpkgs.hostPlatform = "x86_64-linux";
}
