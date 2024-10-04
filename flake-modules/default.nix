{ inputs, ... }:
let
  overlays = builtins.attrValues inputs.self.overlays;
in
{
  imports = [
    ./checks.nix
    ./devshells.nix
    ./docs.nix
    ./example-vm.nix
    ./nixos-modules.nix
    ./nvim.nix
    ./overlays.nix
    ./scripts.nix
  ];

  perSystem =
    { system, pkgs, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs { inherit system overlays; };

      # Nix files formatter (run `nix fmt`)
      formatter = pkgs.nixfmt-rfc-style;
    };
}
