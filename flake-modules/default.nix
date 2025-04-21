{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule

    ./devshells.nix
    ./docs.nix
    ./example-vm.nix
    ./nixos-modules.nix
    ./home-modules.nix
    ./nixvim-modules.nix
    ./overlays.nix
    ../scripts
  ];

  perSystem =
    { system, ... }:
    {
      # Setup formatters
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          rustfmt.enable = true;
          statix.enable = true;
          typos.enable = true;
        };
      };
    };
}
