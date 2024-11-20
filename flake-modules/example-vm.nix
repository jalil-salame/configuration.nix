{ inputs, lib, ... }:
let
  system = "x86_64-linux";
  overlays = builtins.attrValues inputs.self.overlays;
  config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "steam-unwrapped" ];
  pkgs = import inputs.nixpkgs { inherit system overlays config; };
in
{
  # Example vm configuration
  flake.nixosConfigurations.vm = lib.nixosSystem {
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
            dev = {
              enable = true;
              rust.enable = true;
            };
          };
        };
        nix.registry.nixpkgs.flake = inputs.nixpkgs;
        # password is 'test' see module documentation for more options
        services.jupyter.password = "'sha1:1b961dc713fb:88483270a63e57d18d43cf337e629539de1436ba'";
        jconfig = {
          enable = true;
          dev = {
            enable = true;
            jupyter.enable = true;
          };
          gui.enable = true;
        };
      }
    ];
  };

}
