{ lib, ... }:
{
  perSystem =
    { inputs', pkgs, ... }:
    {
      packages =
        let
          filterVisible =
            toplevelOption: option:
            option // { visible = option.visible && builtins.elemAt option.loc 0 == toplevelOption; };
          genOptionsDoc =
            toplevelOption: module:
            pkgs.nixosOptionsDoc {
              inherit (lib.evalModules { modules = [ module ]; }) options;
              transformOptions = filterVisible toplevelOption;
            };
          home = genOptionsDoc "jhome" ../modules/hm/options.nix;
          nvim = genOptionsDoc "jhome" ../modules/nixvim/options.nix;
          nixos = genOptionsDoc "jconfig" ../modules/nixos/options.nix;
          nixos-markdown = nixos.optionsCommonMark;
          home-markdown = home.optionsCommonMark;
          nvim-markdown = nvim.optionsCommonMark;
        in
        {
          docs-home-markdown = home-markdown;
          docs-nixos-markdown = nixos-markdown;
          docs-nvim-markdown = nvim-markdown;
          # Documentation
          docs = pkgs.stdenvNoCC.mkDerivation {
            name = "nixos-configuration-book";
            src = ../docs;

            patchPhase = ''
              cleanup_md() {
                sed \
                  -e 's@\[/nix/store/[^\\]*-source/\(.*\)\\.nix\](.*)@[\1\\.nix](https://github.com/jalil-salame/configuration.nix/blob/main/\1.nix)@' \
                  -e 's/^## /### /' \
                  "$@"
              }
              # copy generated options removing the declared by statement
              cleanup_md ${home-markdown} >> ./src/home-options.md
              cleanup_md ${nvim-markdown} >> ./src/nvim-options.md
              cleanup_md ${nixos-markdown} >> ./src/nixos-options.md
            ''; # FIXME: only add the `/configuration.nix/` part for GH CI

            nativeBuildInputs = [ pkgs.mdbook-toc ];
            buildPhase = "${pkgs.mdbook}/bin/mdbook build --dest-dir $out";
          };
        };
    };
}
