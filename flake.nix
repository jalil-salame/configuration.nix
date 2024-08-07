# This flake was initially generated by fh, the CLI for FlakeHub (version 0.1.9)
{
  # A helpful description of your flake
  description = "My NixOS configuration";
  # Flake inputs
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    unstable.url = "nixpkgs/nixos-unstable";
    # Lix
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.90.0.tar.gz";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.inputs.systems.follows = "systems";
      };
    };
    # Modules
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-24.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "unstable";
        nix-darwin.follows = ""; # disable MacOS stuff
        home-manager.follows = "home-manager";
        flake-compat.follows = "stylix/flake-compat";
        nuschtosSearch.inputs = {
          flake-utils.follows = "lix-module/flake-utils";
          nixpkgs.follows = "nixpkgs";
        };
      };
    };
    # For deduplication
    systems.url = "github:nix-systems/default";
  };

  # Flake outputs that other flakes can use
  outputs =
    {
      self,
      nixpkgs,
      unstable,
      stylix,
      home-manager,
      nixvim,
      lix-module,
      systems,
    }:
    let
      inherit (nixpkgs) lib;
      # Helpers for producing system-specific outputs
      supportedSystems = import systems;
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
      overlays = builtins.attrValues self.overlays;
      scripts_pkgs = import ./scripts;
      scripts = final: prev: scripts_pkgs final;
    in
    {
      checks = forEachSupportedSystem (
        { pkgs, system }:
        let
          src = builtins.path {
            path = ./.;
            name = "configuration.nix";
          };
          runCmdInSrc =
            name: cmd:
            pkgs.runCommandNoCC name { } ''
              cd ${src}
              ${cmd}
              mkdir $out
            '';
        in
        {
          nvim = nixvim.lib.${system}.check.mkTestDerivationFromNixvimModule {
            pkgs = import nixpkgs { inherit system overlays; };
            module = ./nvim/standalone.nix;
          };
          fmt = runCmdInSrc "fmt-src" "${lib.getExe self.formatter.${system}} --check .";
          lint = runCmdInSrc "lint-src" "${lib.getExe pkgs.statix} check .";
          typos = runCmdInSrc "typos-src" "${lib.getExe pkgs.typos} .";
        }
      );

      packages = forEachSupportedSystem (
        { pkgs, system }:
        scripts_pkgs pkgs
        // {
          inherit (import ./docs { inherit pkgs lib; })
            docs
            nixos-markdown
            nvim-markdown
            home-markdown
            ;
          # Nvim standalone module
          nvim = nixvim.legacyPackages.${system}.makeNixvimWithModule {
            pkgs = import nixpkgs { inherit system overlays; };
            module = ./nvim/standalone.nix;
          };
        }
      );

      # Provide necessary overlays
      overlays = {
        inherit scripts;
        nixvim = nixvim.overlays.default;
        unstable =
          final: prev:
          let
            unstablePkgs = unstable.legacyPackages.${prev.system};
          in
          {
            # Get unstable packages
            unstable = unstablePkgs;
            # Update vim plugins with the versions from unstable
            vimPlugins = prev.vimPlugins // unstablePkgs.vimPlugins;
            # Get specific packages from unstable
            inherit (unstablePkgs)
              gitoxide
              jujutsu
              neovim-unwrapped
              wezterm
              ;
          };
      };

      # Nix files formatter (run `nix fmt`)
      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt-rfc-style);

      # Example vm configuration
      nixosConfigurations.vm =
        let
          system = "x86_64-linux";
          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "steam-original" ];
          pkgs = import nixpkgs { inherit system overlays config; };
        in
        lib.nixosSystem {
          inherit system pkgs;
          modules = [
            self.nixosModules.vm # import vm module
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
              nix.registry.nixpkgs.flake = nixpkgs;
              jconfig = {
                enable = true;
                gui.enable = true;
              };
            }
          ];
        };

      nixosModules =
        let
          nvim-config.imports = [
            nixvim.homeManagerModules.nixvim
            ./nvim
          ];
          homeManagerModuleSandalone = import ./home { inherit nvim-config stylix; };
          homeManagerModuleNixOS = import ./home { inherit nvim-config; };
          nixosModule = {
            imports = [
              (import ./system { inherit stylix; })
              home-manager.nixosModules.home-manager
            ] ++ nixpkgs.lib.optional (lix-module != null) lix-module.nixosModules.default;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [ homeManagerModuleNixOS ];
            };
            # Pin nixpkgs
            nix.registry.nixpkgs.flake = nixpkgs;
          };

          machines = [ "vm" ];
          mkMachine = hostname: {
            imports = [
              nixosModule
              (import (./machines + "/${hostname}"))
            ];
            home-manager.sharedModules = [ { jhome.hostName = hostname; } ];
          };
          machineModules = lib.genAttrs machines mkMachine;
        in
        {
          default = nixosModule;
          inherit nixosModule homeManagerModuleNixOS homeManagerModuleSandalone;
        }
        // machineModules;

      devShells = forEachSupportedSystem (
        { pkgs, system }:
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.just
              self.packages.${system}.nvim
            ];
            QEMU_OPTS_WL = "--enable-kvm -smp 4 -device virtio-gpu-rutabaga,gfxstream-vulkan=on,cross-domain=on,hostmem=2G,wsi=headless";
          };
        }
      );
    };
}
