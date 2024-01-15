{ pkgs, lib, ... }:
let
  eval = lib.evalModules { modules = [ ../nixos/options.nix ]; };
  markdown = (pkgs.nixosOptionsDoc { inherit (eval) options; }).optionsCommonMark;
in
{
  inherit markdown;
  docs = pkgs.stdenvNoCC.mkDerivation {
    name = "nixos-configuration-book";
    src = ./.;

    patchPhase = ''
      # copy generated options removing the declared by statement
      sed '/^\*Declared by:\*$/,/^$/d' <${markdown} >> src/options.md
    '';

    buildPhase = "${pkgs.mdbook}/bin/mdbook build --dest-dir $out";
  };
}
