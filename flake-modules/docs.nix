{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages =
        let
          docs-pkg = import ../docs { inherit pkgs lib; };
          inherit (docs-pkg)
            docs
            home-markdown
            nixos-markdown
            nvim-markdown
            ;
        in
        {
          # Documentation
          inherit docs;
          docs-home-markdown = home-markdown;
          docs-nixos-markdown = nixos-markdown;
          docs-nvim-markdown = nvim-markdown;
        };
    };
}
