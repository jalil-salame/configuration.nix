{ self, inputs, ... }:
{
  # FIXME(25.05): this version of HM should have the flake module
  # imports = [ inputs.home-manager.flakeModules.home-manager ];

  flake.homeModules =
    let
      defaultModules = [
        inputs.nixvim.homeManagerModules.nixvim
        self.nixvimModules.homeManager
        ../modules/hm
      ];
      nixos = {
        imports = defaultModules;
      };
      standalone = {
        imports = defaultModules ++ [
          inputs.stylix.homeManagerModules.stylix
          (
            { config, ... }:
            {
              stylix.image = config.jhome.sway.background;
            }
          )
        ];
      };
    in
    {
      inherit standalone nixos;
    };
}
