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
            { lib, config, ... }:
            let
              cfg = config.jhome;
            in
            {
              imports = [ (import ../modules/shared/starship.nix { inherit cfg; }) ];
              config = lib.mkMerge [
                {
                  nixpkgs.overlays = [
                    inputs.self.overlays.unstable
                    inputs.lix-module.overlays.default
                  ];
                }
                (lib.mkIf cfg.gui.enable { stylix.image = cfg.gui.sway.background; })
              ];
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
