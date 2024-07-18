# Autodetects files with a package.nix and calls `callPackage` on them.
#
# Will add a package .#dirname to the flake if it finds a ./dirname/package.nix file.
let
  files = builtins.readDir ./.;
  isPackage = path: type: (type == "directory") && (builtins.readDir path) ? "package.nix";
  toPackage = name: pkgs: {
    inherit name;
    value = pkgs.callPackage (./. + "/${name}/package.nix") { };
  };
  # call pkgs.callPackage on all ./*/package.nix
  makePackage =
    pkgs: name:
    let
      type = files.${name};
      path = ./. + "/${name}";
      package = toPackage name pkgs;
    in
    # if it is a package then return a package otherwise return no package c:
    if isPackage path type then [ package ] else [ ];
in
# we have lib.filterMapAttrs at home
pkgs: builtins.listToAttrs (builtins.concatMap (makePackage pkgs) (builtins.attrNames files))
