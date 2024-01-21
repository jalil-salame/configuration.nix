{ pkgs, lib }:
let
  nixos-eval = lib.evalModules { modules = [ ../nixos/options.nix ]; };
  home-eval = lib.evalModules { modules = [ ../home/options.nix ]; };
  nixos-markdown = (pkgs.nixosOptionsDoc {
    inherit (nixos-eval) options;
    transformOptions = option: option // { visible = option.visible && builtins.elemAt option.loc 0 == "jconfig"; };
  }).optionsCommonMark;
  home-markdown = (pkgs.nixosOptionsDoc {
    inherit (home-eval) options;
    transformOptions = option: option // { visible = option.visible && builtins.elemAt option.loc 0 == "jconfig"; };
  }).optionsCommonMark;
in
{
  inherit nixos-markdown home-markdown;
  docs = pkgs.stdenvNoCC.mkDerivation {
    name = "nixos-configuration-book";
    src = ./.;

    patchPhase = ''
      # copy generated options removing the declared by statement
      sed '/^\*Declared by:\*$/,/^$/d' <${home-markdown} >> src/home-options.md
      sed '/^\*Declared by:\*$/,/^$/d' <${nixos-markdown} >> src/nixos-options.md
    '';

    buildPhase = "${pkgs.mdbook}/bin/mdbook build --dest-dir $out";
  };
}
