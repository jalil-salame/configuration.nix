_: {
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        buildInputs = [
          pkgs.just
          self'.packages.nvim
        ];
        QEMU_OPTS_WL = "--enable-kvm -smp 4 -device virtio-gpu-rutabaga,gfxstream-vulkan=on,cross-domain=on,hostmem=2G,wsi=headless";
      };
    };
}
