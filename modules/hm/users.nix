{ config, lib, ... }:
let
  inherit (config) jhome;
  inherit (cfg.defaultIdentity) signingKey;

  cfg = jhome.user;
  hasKey = signingKey != null;
in
{
  config = lib.mkIf (jhome.enable && cfg != null) {
    programs = {
      git = {
        userName = cfg.defaultIdentity.name;
        userEmail = cfg.defaultIdentity.email;
        signing = lib.mkIf hasKey {
          signByDefault = true;
          key = signingKey;
        };
      };

      jujutsu.settings = {
        user = lib.mkIf (cfg.defaultIdentity != null) { inherit (cfg.defaultIdentity) name email; };
        git.sign-on-push = lib.mkDefault hasKey;
        signing = lib.mkIf hasKey {
          behaviour = "own";
          backend = "gpg";
          key = signingKey;
        };
      };
    };

    xdg.configFile.pam-gnupg = lib.mkIf (cfg.unlockKeys != [ ]) {
      text = ''
        ${config.programs.gpg.homedir}

        ${lib.strings.concatLines cfg.gpg.unlockKeys}
      '';
    };
  };
}
