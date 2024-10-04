{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        # Documentation
        inherit (import ../docs { inherit pkgs lib; })
          docs
          nixos-markdown
          nvim-markdown
          home-markdown
          ;
      };
    };
}
