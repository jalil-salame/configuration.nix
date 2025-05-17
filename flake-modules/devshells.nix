_: {
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        buildInputs = [
          pkgs.just
          self'.packages.nvim
          pkgs.uv
        ];
        QEMU_OPTS_WL = "-enable-kvm -nodefaults -m 4G -cpu host -smp 4 -device virtio-gpu";
      };
    };
}
