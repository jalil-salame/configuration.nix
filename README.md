# My NixOS Configuration as a NixOS module

This is only intended for my use, but you can see how I overengineer stuff by
looking at it :p (maybe you can also learn some stuff on the way).

## Try out in a VM

If you already have nix you can run the following commands:

```console
$ nix run nixpkgs#nixos-rebuild -- build-vm --flake .#vm
building the system configuration...

Done.  The virtual machine can be started by running /nix/store/$hash-nixos-vm/bin/run-nixos-vm
$ /nix/store/$hash-nixos-vm/bin/run-nixos-vm -vga virtio
```

The default user is `jdoe` and the default password is `example`.

> [!Note]
> The `-vga virtio` flag is important, sway won't run if it is missing.
