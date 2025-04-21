{ lib, ... }:
let
  src = ./.;
  # Autodetects files with a package.nix and calls `callPackage` on them.
  #
  # Will add a package .#dirname to the flake if it finds a ./dirname/package.nix file.
  files = builtins.readDir src;
  isPackage = path: type: (type == "directory") && (builtins.readDir path) ? "package.nix";
  toPackage = name: pkgs: {
    inherit name;
    value = pkgs.callPackage "${src}/${name}/package.nix" { };
  };
  # call pkgs.callPackage on all ./*/package.nix
  makePackage =
    pkgs: name:
    let
      type = files.${name};
      path = "${src}/${name}";
      package = toPackage name pkgs;
    in
    # if it is a package then return a package otherwise return no package c:
    if isPackage path type then [ package ] else [ ];
  # we have lib.filterMapAttrs at home
  scripts =
    pkgs: builtins.listToAttrs (builtins.concatMap (makePackage pkgs) (builtins.attrNames files));
in
{
  # Add scripts to overlay
  flake.overlays.scripts = final: scripts;

  # Add scripts to packages
  perSystem =
    { pkgs, ... }:
    {
      packages = scripts pkgs;
    };
}
