{ lib, config, ... }:
let
  cfg = config.jconfig.dev;
in
{
  config = lib.mkIf (config.jconfig.enable && cfg.enable) {
    # Enable dev documentation
    documentation.dev = { inherit (cfg) enable; };

    users.extraUsers = lib.mkIf cfg.jupyter.enable { jupyter.group = "jupyter"; };

    services.jupyter = {
      inherit (cfg.jupyter) enable;
      group = "jupyter";
      user = "jupyter";
    };
  };
}
