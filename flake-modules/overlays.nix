{ inputs, ... }:
{
  flake.overlays = {
    # Add unstable packages to overlay
    unstable = final: prev: {
      unstable = inputs.unstable.legacyPackages.${prev.stdenv.hostPlatform.system};

      # Prefer unstable vimPlugins
      vimPlugins = prev.vimPlugins // final.unstable.vimPlugins;
    };

    # Use lix for most packages
    lix = final: prev: {
      inherit (prev.lixPackageSets.latest)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    };
  };
}
