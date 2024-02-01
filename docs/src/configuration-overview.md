# Nix Based Configuration

I use [NixOS](https://nixos.org) and
[home-manager](https://github.com/nixos-community/home-manager) to manage my
system and user configuration respectively. You can see what options I have
added to configure the system and user configuration in the next chapters.

<!-- toc -->

## How to Use

If you are not me, then you probably shouldn't use this, but feel free to draw
inspiration from what I have done c:.

First you want to see what your environment is; if you are using NixOS then you
want to look at the [NixOS Module Setup](#nixos-module-setup), if you are just
using home-manager, then you should look at the [homa-manager Module
Setup](#home-manager-module-setup).

### NixOS Module Setup

> Although I am talking about the NixOS module setup, this uses both NixOS and
> home-manager, so you can (and should) use both modules.

#### Setup from LiveISO

Follow the [NixOS Manual](https://nixos.org/manual/nixos/stable) until before
you run `nixos-generate-config`.

First you will want to create a directory for your NixOS configuration. I like
using `~/.config/nixos`. You then want to run `nixos-generate-config --root /mnt
--dir ~/.config/nixos` (assuming you mounted your filesystem to `/mnt`). Now you
have `configuration.nix` and `hardware-configuration.nix` inside
`~/.config/nixos`. I like renaming `configuration.nix` to `default.nix` and
putting it in a folder with the same hostname as the machine (See [the source
repo](https://github.com/jalil-salame/configuration.nix/tree/main/machines)).

Now you can add a `flake.nix` file to your `~/.config/nixos` and make it a flake
based configuration. This is the general structure you'll want:

```nix
{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  # My custom configuration module
  inputs.config.url = "github:jalil-salame/configuration.nix";
  inputs.config.inputs.follows.nixpkgs = "nixpkgs";

  outputs = { self, nixpkgs, config }: let
    pc = import (./. + hostname);
    hostname = "nixos";
    system = "x86_64-linux";
    overlays = builtins.attrValues config.overlays;
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "steam-original"
    ];
    pkgs = import nixpkgs { inherit system overlays config; };
  in {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        # My configuration module (includes home-manager)
        config.nixosModules.nixosModule
        # Results from `nixos-generate-config`
        pc
        # Custom options (see module configuration options)
        {
          # Enable my custom configuration
          jconfig.enable = true;
          jconfig.gui.enable = true; # Enable gui environment

          # Add users to use with home-manager
          users.users = {};

          # You should probably also enable wifi if needed

          # Add home-manager users configuration (here you can enable jhome options)
          home-manager.users = {};
          # home-manager globally set options
          home-manager.sharedModules = [{ jhome.hostName = hostname; }];
        }
      ];
    };
  };
}
```

Now you should be ready to do `sudo nixos-rebuild switch --flake .#$hostname`
and use the configuration c:.

### home-manager Module Setup

If you are not using NixOS, then you probably want to only use the home-manager
configuration. In that case, you want to use the
`nixosModules.homeManagerModuleSandalone` in your `home-manager` configuration,
and probably disable GUI applications all together `jhome.gui.enable = false`.

Your flake should then look like this (follow the [home-manager
Manual](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-standalone)
for more information):

```nix
{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.home-manager.url = "github:nixos-community/home-manager";
  inputs.home-manager.inputs.follows.nixpkgs = "nixpkgs";

  # My custom configuration module
  inputs.config.url = "github:jalil-salame/configuration.nix";
  inputs.config.inputs.follows.nixpkgs = "nixpkgs";
  inputs.config.inputs.follows.home-manager = "home-manager";

  outputs = { self, nixpkgs, home-manager, config }: let
    hostname = "nixos";
    username = "jdoe";
    system = "x86_64-linux";
    overlays = builtins.attrValues config.overlays;
    pkgs = import nixpkgs { inherit system overlays; };
  in {
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        # My configuration module (includes home-manager)
        config.nixosModules.homeManagerModuleSandalone
        # Custom options (see module configuration options and home-manager options)
        {
          # Enable my custom configuration
          jhome.enable = true;
          jhome.hostName = hostname;
          jhome.gui.enable = false;

          # Extra configuration options
        }
      ];
    };
  };
}
```
