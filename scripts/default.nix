let
  packages = pkgs: {
    jpassmenu = pkgs.callPackage ./jpassmenu/package.nix { };
    audiomenu = pkgs.callPackage ./audiomenu/package.nix { };
  };
in
{
  # Add scripts to overlay
  flake.overlays.scripts = _final: packages;

  # Add scripts to packages
  perSystem =
    { pkgs, ... }:
    {
      packages = packages pkgs;
    };
}
