{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        buildInputs = [
          self'.packages.nvim

          pkgs.just
          pkgs.nix-diff
          pkgs.nvd
          pkgs.uv
        ];
        QEMU_OPTS_WL = "-enable-kvm -nodefaults -m 4G -cpu host -smp 4 -display gtk,gl=on,grab-on-hover=on -device virtio-gpu-gl";
      };
    };
}
