{ inputs, ... }:
{
  # Add unstable channel to pkgs
  flake.overlays.unstable = final: prev: {
    unstable = inputs.unstable.legacyPackages.${prev.stdenv.hostPlatform.system};
  };
}
