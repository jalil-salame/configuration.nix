{ pkgs, lib }:
let
  # can be removed once https://github.com/rust-lang/mdBook/pull/2262 lands
  highlight = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rust-lang/mdBook/7b9bd5049ce15ae5f301d5a40c50ce8359d9e9a8/src/theme/highlight.js";
    hash = "sha256-pLP73zlmGkbC/zV6bwnB6ijRf9gVkj5/VYMGLhiQ1/Q=";
  };
  filterVisible =
    toplevelOption: option:
    option // { visible = option.visible && builtins.elemAt option.loc 0 == toplevelOption; };
  home-eval = lib.evalModules {
    modules = [ ../home/options.nix ];
    specialArgs = {
      inherit pkgs;
    };
  };
  nvim-eval = lib.evalModules { modules = [ ../nvim/options.nix ]; };
  nixos-eval = lib.evalModules { modules = [ ../system/options.nix ]; };
  home-markdown =
    (pkgs.nixosOptionsDoc {
      inherit (home-eval) options;
      transformOptions = filterVisible "jhome";
    }).optionsCommonMark;
  nvim-markdown =
    (pkgs.nixosOptionsDoc {
      inherit (nvim-eval) options;
      transformOptions = filterVisible "jhome";
    }).optionsCommonMark;
  nixos-markdown =
    (pkgs.nixosOptionsDoc {
      inherit (nixos-eval) options;
      transformOptions = filterVisible "jconfig";
    }).optionsCommonMark;
in
{
  inherit nixos-markdown nvim-markdown home-markdown;
  docs = pkgs.stdenvNoCC.mkDerivation {
    name = "nixos-configuration-book";
    src = ./.;

    patchPhase = ''
      mkdir -p ./theme
      ln -s ${highlight} ./theme/highlight.js

      cat > sed-cmds <<EOF
      # Replace nix store path to github url
      s:\[/nix/store/[^\\]*-source/\(.*\)\\.nix\](.*):[\1\\.nix](https\://github.com/jalil-salame/configuration.nix/blob/main/\1.nix):
      # Make <h2> <h3>
      s/^## /### /
      EOF
      # copy generated options removing the declared by statement
      sed -f sed-cmds <${home-markdown} >> ./src/home-options.md
      sed -f sed-cmds <${nvim-markdown} >> ./src/nvim-options.md
      sed -f sed-cmds <${nixos-markdown} >> ./src/nixos-options.md
    '';

    nativeBuildInputs = [ pkgs.mdbook-toc ];
    buildPhase = "${pkgs.mdbook}/bin/mdbook build --dest-dir $out";
  };
}
