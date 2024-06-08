{
  lib,
  stdenvNoCC,
  statix,
  src,
}:
stdenvNoCC.mkDerivation {
  name = "lint-src";
  inherit src;
  buildPhase = "${lib.getExe statix} check .";
  installPhase = "mkdir $out";
}
