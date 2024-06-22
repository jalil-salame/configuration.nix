{
  lib,
  pkgs,
  config,
  helpers,
  ...
}: let
  # Force inputs to be included
  nixvim = import ./nixvim.nix {inherit lib pkgs config helpers;};
in {
  imports = [./options.nix];

  config.programs.nixvim = nixvim.config;
}
