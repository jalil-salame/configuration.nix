{ lib, rustPlatform }:
let
  cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
  inherit (cargoToml.package) name version description;
  pname = name;
  src = lib.cleanSourceWith {
    src = ./.;
    name = "${pname}-source";
    # Adapted from <https://github.com/ipetkov/crane/blob/master/lib/filterCargoSources.nix>
    # no need to pull in crane for just this
    filter =
      orig_path: type:
      let
        path = toString orig_path;
        base = baseNameOf path;
        parentDir = baseNameOf (dirOf path);
        matchesSuffix = lib.any (suffix: lib.hasSuffix suffix base) [
          # Rust sources
          ".rs"
          # TOML files are often used to configure cargo based tools (e.g. .cargo/config.toml)
          ".toml"
        ];
        isCargoLock = base == "Cargo.lock";
        # .cargo/config.toml is captured above
        isOldStyleCargoConfig = parentDir == ".cargo" && base == "config";
      in
      type == "directory" || matchesSuffix || isCargoLock || isOldStyleCargoConfig;
  };
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
