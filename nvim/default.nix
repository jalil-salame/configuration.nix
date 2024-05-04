{pkgs, ...} @ opts: {
  imports = [./options.nix];

  config.programs.nixvim = (import ./nixvim.nix opts).config;
}
