{ config, lib, ... }:
let
  inherit (config) jhome;
  inherit (cfg.defaultIdentity) signingKey;

  cfg = jhome.user;
  hasConfig = jhome.enable && cfg != null;
  hasKey = signingKey != null;
  gpgHome = config.programs.gpg.homedir;
  unlockKey = hasConfig && cfg.gpg.unlockKeys != [ ];
in
{
  config = lib.mkMerge [
    (lib.mkIf hasConfig {
      programs.git = {
        userName = cfg.defaultIdentity.name;
        userEmail = cfg.defaultIdentity.email;
        signing = lib.mkIf hasKey {
          signByDefault = true;
          key = signingKey;
        };
      };
      programs.jujutsu.settings = {
        user = lib.mkIf (cfg.defaultIdentity != null) { inherit (cfg.defaultIdentity) name email; };
        signing = lib.mkIf hasKey {
          sign-all = true;
          backend = "gpg";
          key = signingKey;
        };
      };
    })
    (lib.mkIf unlockKey {
      xdg.configFile.pam-gnupg.text =
        ''
          ${gpgHome}

        ''
        + (lib.strings.concatLines cfg.gpg.unlockKeys);
    })
  ];
}
