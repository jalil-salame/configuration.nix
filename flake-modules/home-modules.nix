{ self, inputs, ... }:
{
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  flake =
    { lib, ... }:
    {
      homeModules =
        let
          defaultModules = [
            inputs.nixvim.homeModules.nixvim
            self.nixvimModules.homeManager
            ../modules/hm
          ];
          standaloneModule =
            { pkgs, config, ... }:
            let
              cfg = config.jhome;
            in
            {
              imports = [ (import ../modules/shared/starship.nix { inherit cfg; }) ];
              config = {
                nixpkgs.overlays = [
                  inputs.self.overlays.unstable
                  inputs.lix-module.overlays.default
                ];
                stylix = {
                  image = cfg.gui.wallpaper;
                  base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
                };
              };
            };
        in
        {
          nixos = lib.mkMerge defaultModules;
          standalone = lib.mkMerge (
            defaultModules
            ++ [
              inputs.stylix.homeModules.stylix
              standaloneModule
            ]
          );
        };
    };
}
