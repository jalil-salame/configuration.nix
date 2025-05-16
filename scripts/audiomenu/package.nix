{
  lib,
  rustPlatform,
  cleanRustSrc,
}:
let
  cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
  inherit (cargoToml.package) name version description;
  pname = name;
  src = cleanRustSrc ./.;
in
rustPlatform.buildRustPackage {
  inherit pname version src;
  cargoLock.lockFile = ./Cargo.lock;
  useNextest = true;
  meta = {
    inherit description;
    license = lib.licenses.mit;
    homepage = "https://github.com/jalil-salame/configuration.nix";
    mainProgram = name;
  };
}
