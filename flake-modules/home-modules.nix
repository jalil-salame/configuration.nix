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
      nixos = {
        imports = defaultModules;
      };
      standalone = {
        imports = defaultModules ++ [
          inputs.stylix.homeModules.stylix
          (
            { lib, config, ... }:
            lib.mkIf config.jhome.gui.enable {
              stylix.image = config.jhome.gui.sway.background;
            }
          )
        ];
      };
    in
    {
      inherit standalone nixos;
    };
}
