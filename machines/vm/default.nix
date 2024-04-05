{ ... }:
{
  services.qemuGuest.enable = true;

  boot.initrd.availableKernelModules = [
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
  fileSystems."/".device = "/dev/disk/by-label/nixos";

  boot.loader.systemd-boot.enable = true;

  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
