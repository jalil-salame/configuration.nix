{ pkgs, lib }:
let
  # can be removed once https://github.com/rust-lang/mdBook/pull/2262 lands
  highlight = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rust-lang/mdBook/7b9bd5049ce15ae5f301d5a40c50ce8359d9e9a8/src/theme/highlight.js";
    hash = "sha256-pLP73zlmGkbC/zV6bwnB6ijRf9gVkj5/VYMGLhiQ1/Q=";
  };
  filterVisible = toplevelOption: option: option // { visible = option.visible && builtins.elemAt option.loc 0 == toplevelOption; };
  home-eval = lib.evalModules { modules = [ ../home/options.nix ]; specialArgs = { inherit pkgs; }; };
  nvim-eval = lib.evalModules { modules = [ ../nvim/options.nix ]; };
  nixos-eval = lib.evalModules { modules = [ ../nixos/options.nix ]; };
  home-markdown = (pkgs.nixosOptionsDoc { inherit (home-eval) options; transformOptions = filterVisible "jhome"; }).optionsCommonMark;
  nvim-markdown = (pkgs.nixosOptionsDoc { inherit (nvim-eval) options; transformOptions = filterVisible "jhome"; }).optionsCommonMark;
  nixos-markdown = (pkgs.nixosOptionsDoc { inherit (nixos-eval) options; transformOptions = filterVisible "jconfig"; }).optionsCommonMark;
in
{
  inherit nixos-markdown nvim-markdown home-markdown;
  docs = pkgs.stdenvNoCC.mkDerivation {
    name = "nixos-configuration-book";
    src = ./.;

    patchPhase = ''
      mkdir -p ./theme
      ln -s ${highlight} ./theme/highlight.js

      # copy generated options removing the declared by statement
      sed '/^\*Declared by:\*$/,/^$/d' <${home-markdown} >> ./src/home-options.md
      sed '/^\*Declared by:\*$/,/^$/d' <${nvim-markdown} >> ./src/nvim-options.md
      sed '/^\*Declared by:\*$/,/^$/d' <${nixos-markdown} >> ./src/nixos-options.md
    '';

    nativeBuildInputs = [ pkgs.mdbook-toc ];
    buildPhase = "${pkgs.mdbook}/bin/mdbook build --dest-dir $out";
  };
}
