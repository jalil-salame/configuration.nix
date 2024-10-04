{ inputs, lib, ... }:
{
  # Example vm configuration
  flake.nixosConfigurations.vm =
    let
      system = "x86_64-linux";
      overlays = builtins.attrValues inputs.self.overlays;
      config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "steam-original" ];
      pkgs = import inputs.nixpkgs { inherit system overlays config; };
    in
    lib.nixosSystem {
      inherit system pkgs;
      modules = [
        inputs.self.nixosModules.vm # import vm module
        {
          time.timeZone = "Europe/Berlin";
          i18n.defaultLocale = "en_US.UTF-8";
          users.users.jdoe = {
            password = "example";
            isNormalUser = true;
            extraGroups = [
              "wheel"
              "video"
              "networkmanager"
            ];
          };
          home-manager.users.jdoe = {
            home = {
              username = "jdoe";
              homeDirectory = "/home/jdoe";
            };
            jhome = {
              enable = true;
              gui.enable = true;
              dev.rust.enable = true;
            };
          };
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
          jconfig = {
            enable = true;
            gui.enable = true;
          };
        }
      ];
    };
}
