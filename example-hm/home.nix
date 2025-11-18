{
  lib,
  pkgs,
  config,
  ...
}:
{
  home = {
    homeDirectory = "/home/jdoe";
    stateVersion = "25.05";
    username = "jdoe";
  };

  jhome = {
    enable = true;
    dev = {
      enable = true;
      neovimAsManPager = true;
      rust.enable = true;
    };
    gui.enable = false;
    hostName = "example";
    user = {
      enable = true;
      defaultIdentity = {
        email = "jdoe@example.org";
        name = "John Doe";
      };
    };
  };

  programs = {
    # Switch to fish if bash is started interactively
    bash.initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';

    # Enable zellij (tmux like terminal session manager)
    zellij.enable = lib.mkForce true;
  };

  nix = {
    package = pkgs.lixPackageSets.latest.lix; # use lix
    gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 30d";
      # run between 0 and 45min after boot if run was missed
      randomizedDelaySec = "45min";
    };
    settings = {
      # Add my personal binary cache to the mix (only for personal computers)
      extra-substituters = [ "https://cache.salame.cl" ];
      extra-trusted-public-keys = [ "cache.salame.cl:D+pBaoutwxja7qKGpju+CmM1LRbVmf2gqEQ/9c7qHrw=" ];
      auto-optimise-store = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
