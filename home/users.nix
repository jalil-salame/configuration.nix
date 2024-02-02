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
      programs.git.userName = cfg.defaultIdentity.name;
      programs.git.userEmail = cfg.defaultIdentity.email;
      programs.git.signing = lib.mkIf hasKey {
        signByDefault = true;
        key = signingKey;
      };
    })
    (lib.mkIf unlockKey {
      xdg.configFile.pam-gnupg.text = ''
        ${gpgHome}

      '' + (lib.strings.concatLines cfg.gpg.unlockKeys);
    })
  ];
}
