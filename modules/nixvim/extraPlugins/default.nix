{ pkgs }:
let
  overlay = pkgs.callPackage ./generated.nix {
    inherit (pkgs.vimUtils) buildVimPlugin buildNeovimPlugin;
  };
  plugins = overlay pkgs pkgs;
in
{
  inherit overlay;
  inherit (plugins) nvim-silicon;
}
