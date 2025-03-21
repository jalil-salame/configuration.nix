{
  imports = [ ./vm-config.nix ];

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
