{
  pkgs,
  config,
  lib,
  ...
}:
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
        # Use the more up-to-date version of jj
        user = lib.mkIf (cfg.defaultIdentity != null) { inherit (cfg.defaultIdentity) name email; };
        git.sign-on-push = lib.mkDefault hasKey;
        # Setup Key
        signing = lib.mkIf hasKey { key = signingKey; };
      };
    };

    xdg.configFile.pam-gnupg = lib.mkIf (cfg.gpg.unlockKeys != [ ]) {
      text = ''
        ${config.programs.gpg.homedir}

        ${lib.strings.concatLines cfg.gpg.unlockKeys}
      '';
    };
  };
}
