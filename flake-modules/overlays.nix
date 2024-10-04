{ inputs, ... }:
{
  # Add unstable packages to overlay
  flake.overlays.unstable =
    final: prev:
    let
      unstablePkgs = inputs.unstable.legacyPackages.${prev.stdenv.hostPlatform.system};
    in
    {
      # Get unstable packages
      unstable = unstablePkgs;

      # Update vim plugins with the versions from unstable
      vimPlugins = prev.vimPlugins // unstablePkgs.vimPlugins;

      # Get specific packages from unstable
      inherit (unstablePkgs)
        gitoxide
        jujutsu
        neovim-unwrapped
        ruff # nixpkgs stable version is improperly configured by nixvim
        # wezterm
        ;
    };

}
