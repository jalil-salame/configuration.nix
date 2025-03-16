{ lib, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages =
        let
          modules = ../modules;
          filterVisible =
            toplevelOption: option:
            option // { visible = option.visible && builtins.elemAt option.loc 0 == toplevelOption; };
          home-eval = lib.evalModules {
            modules = [ (modules + "/hm/options.nix") ];
            specialArgs = {
              inherit pkgs;
            };
          };
          nvim-eval = lib.evalModules { modules = [ (modules + "/nixvim/options.nix") ]; };
          nixos-eval = lib.evalModules { modules = [ (modules + "/nixos/options.nix") ]; };
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
          docs-home-markdown = home-markdown;
          docs-nixos-markdown = nixos-markdown;
          docs-nvim-markdown = nvim-markdown;
          # Documentation
          docs = pkgs.stdenvNoCC.mkDerivation {
            name = "nixos-configuration-book";
            src = inputs.self + "/docs";

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
            '';

            nativeBuildInputs = [ pkgs.mdbook-toc ];
            buildPhase = "${pkgs.mdbook}/bin/mdbook build --dest-dir $out";
          };
        };
    };
}
