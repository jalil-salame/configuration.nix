# Nix Based Configuration

I use [NixOS](https://nixos.org) and
[home-manager](https://github.com/nixos-community/home-manager) to manage my
system and user configuration respectively. You can see what options I have
added to configure the system and user configuration in the next chapters.

The source repo is
[configuration.nix](https://github.com/jalil-salame/configuration.nix).

## Table of Contents

<!-- toc -->

## How to Use

If you are not me, then you probably shouldn't use this, but feel free to draw
inspiration from what I have done c:.

First you want to see what your environment is; if you are using NixOS then you
want to look at the [NixOS Module Setup](#nixos-module-setup), if you are just
using home-manager, then you should look at the [homa-manager Module
Setup](#home-manager-module-setup). Or if you just want to use my NeoVIM
configuration then look at the [NeoVIM standalone
setup](#neovim-standalone-setup).

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
repo](https://github.com/jalil-salame/configuration.nix/tree/main/example-vm)).

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
  in {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      modules = [
        # My configuration module (includes home-manager)
        config.nixosModules.nixosModule
        # Results from `nixos-generate-config`
        pc
        # Custom options (see module configuration options)
        {
          nixpkgs = {
            overlays = builtins.attrValues inputs.self.overlays;
            config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "steam-unwrapped" ];
          };

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

See the [example
configuration](https://github.com/jalil-salame/configuration.nix/tree/main/example-vm))
for a more up to date configuration.

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
  in {
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        # My configuration module (includes home-manager)
        config.homeModules.standalone
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

See the [example
configuration](https://github.com/jalil-salame/configuration.nix/tree/main/example-hm))
for a more up to date configuration.

### NeoVIM Standalone setup

My NeoVIM configuration is managed by
[NixVIM](https://github.com/nix-community/nixvim), so check that project out if
you want to understand how it works. You can use [this
tutorial](https://nix-community.github.io/nixvim/user-guide/extending-config.html)
to extend my configuration without forking this repo or copying its files.

If you want to test out my configuration then you can run this handy nix
command:

```console
$ nix run github:jalil-salame/configuration.nix#nvim
```

It will download and build my NeoVIM configuration and run NeoVIM. Alternatively
you can replace `nix run` with `nix shell` which will temporarily add my NeoVIM
configuration to your shell and when you run `nvim` it will launch it.
