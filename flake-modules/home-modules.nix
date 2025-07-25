{ self, inputs, ... }:
{
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  flake.homeModules =
    let
      defaultModules = [
        inputs.nixvim.homeModules.nixvim
        self.nixvimModules.homeManager
        ../modules/hm
      ];
    in
    {
      nixos.imports = defaultModules;
      standalone.imports = defaultModules ++ [
        inputs.stylix.homeModules.stylix
        (
          { lib, config, ... }:
          lib.mkMerge [
            {
              nixpkgs.overlays = [
                inputs.self.overlays.unstable
                inputs.lix-module.overlays.default
              ];
            }
            (lib.mkIf config.jhome.gui.enable {
              stylix.image = config.jhome.gui.sway.background;
            })
          ]
        )
      ];
    };
}
