{
  lib,
  stdenvNoCC,
  typos,
  src,
}:
stdenvNoCC.mkDerivation {
  name = "typos-src";
  inherit src;
  buildPhase = "${lib.getExe typos} .";
  installPhase = "mkdir $out";
}
