{
  lib,
  stdenvNoCC,
  alejandra,
  src,
}:
stdenvNoCC.mkDerivation {
  name = "fmt-src";
  inherit src;
  buildPhase = "${lib.getExe alejandra} --check .";
  installPhase = "mkdir $out";
}
