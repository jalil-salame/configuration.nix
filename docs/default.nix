{ pkgs, lib, ... }:
let
  eval = lib.evalModules { modules = [ ../options.nix ]; };
  doc = (pkgs.nixosOptionsDoc { inherit (eval) options; }).optionsCommonMark;
in
pkgs.stdenvNoCC.mkDerivation {
  name = "nixos-configuration-book";
  src = ./.;

  patchPhase = ''
    # copy generated options removing the declared by statement
    sed '/^\*Declared by:\*$/,/^$/d' <${doc} >> src/options.md
  '';

  buildPhase = "${pkgs.mdbook}/bin/mdbook build --dest-dir $out";
}
