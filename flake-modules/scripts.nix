let
  scripts = import ../scripts;
in
{
  # Add scripts to overlay
  flake.overlays.scripts = final: prev: scripts final;

  # Add scripts to packages
  perSystem =
    { pkgs, ... }:
    {
      packages = scripts pkgs;
    };
}
