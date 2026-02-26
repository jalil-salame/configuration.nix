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
            inputs.catppuccin.homeModules.catppuccin
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
                  inputs.self.overlays.lix
                ];
              };
            };
        in
        {
          nixos = lib.mkMerge defaultModules;
          standalone = lib.mkMerge (defaultModules ++ [ standaloneModule ]);
        };
    };
}
