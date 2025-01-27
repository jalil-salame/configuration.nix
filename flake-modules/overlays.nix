{ inputs, ... }:
{
  # Add unstable packages to overlay
  flake.overlays.unstable = final: prev: {
    unstable = inputs.unstable.legacyPackages.${prev.stdenv.hostPlatform.system};

    # use unstable vimPlugins
    vimPlugins = prev.vimPlugins // final.unstable.vimPlugins;
  };
}
