# My NixOS Configuration as a NixOS module

This is only intended for my use, but you can see how I overengineer stuff by
looking at it :p (maybe you can also learn some stuff on the way).

> [!Note]
> This README only has a small amount of information, if you want to see the
> full documentation then go to
> <https://jalil-salame.github.io/configuration.nix>. I also overenginerd this
> c: (if you want to copy the docs for your own project, then take a look at
> [the docs folder](./docs/default.nix) and the
> [workflow](./.github/workflows/check.yml)(`build-documentation` and
> `deploy`)).

## Try out in a VM

If you already have nix you can run the following commands:

```console
$ nix run nixpkgs#nixos-rebuild -- build-vm --flake .#vm
building the system configuration...

Done.  The virtual machine can be started by running /nix/store/$hash-nixos-vm/bin/run-nixos-vm
$ /nix/store/$hash-nixos-vm/bin/run-nixos-vm $QEMU_OPTS_WL
```

The default user is `jdoe` and the default password is `example`.

> [!Note]
> `$QEMU_OPTS_WL` is a set of options that will enable Wayland passthrough (and
> GPU acceleration) and give the VM 2vCPU cores and 2GiB of RAM. This will
> significantly improve your experience when running the VM so it is
> recommended, but if Wayland is not available or you don't have enough
> memory/CPU cores, then you can use `-virtio vga` and/or reduce the allocated
> resources.
