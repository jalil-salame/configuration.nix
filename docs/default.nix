{ pkgs, lib, markdown }:
let
  eval = lib.evalModules { modules = [ ../nixos/options.nix ]; };
  nixos-markdown = (pkgs.nixosOptionsDoc {
    inherit (eval) options;
    transformOptions = option: option // { visible = option.visible && builtins.elemAt option.loc 0 == "jconfig"; };
  }).optionsCommonMark;
in
{
  markdown = nixos-markdown;
  docs = pkgs.stdenvNoCC.mkDerivation {
    name = "nixos-configuration-book";
    src = ./.;

    patchPhase = ''
      # copy generated options removing the declared by statement
      sed '/^\*Declared by:\*$/,/^$/d' <${markdown} >> src/home-options.md
      sed '/^\*Declared by:\*$/,/^$/d' <${nixos-markdown} >> src/nixos-options.md
    '';

    buildPhase = "${pkgs.mdbook}/bin/mdbook build --dest-dir $out";
  };
}
