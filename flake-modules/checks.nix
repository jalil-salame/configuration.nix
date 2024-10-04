{ lib, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    {
      checks =
        let
          src = builtins.path {
            path = ../.;
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
          fmt = runCmdInSrc "fmt-src" "${lib.getExe self'.formatter} --check .";
          lint = runCmdInSrc "lint-src" "${lib.getExe pkgs.statix} check .";
          typos = runCmdInSrc "typos-src" "${lib.getExe pkgs.typos} .";
        };
    };
}
