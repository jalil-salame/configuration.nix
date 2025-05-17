{ lib, ... }:
let
  # Clean the package source leaving only the relevant rust files
  cleanRustSrc =
    pname: src:
    lib.cleanSourceWith {
      inherit src;
      name = "${pname}-source";
      # Adapted from <https://github.com/ipetkov/crane/blob/master/lib/filterCargoSources.nix>
      # no need to pull in crane for just this
      filter =
        orig_path: type:
        let
          path_str = toString orig_path;
          base = baseNameOf path_str;
          parentDir = baseNameOf (dirOf path_str);
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
  # callPackage but for my rust Packages
  callRustPackage =
    pkgs: pname: nixSrc:
    pkgs.callPackage nixSrc { cleanRustSrc = cleanRustSrc pname; };
  packages = pkgs: {
    jpassmenu = pkgs.callPackage ./jpassmenu/package.nix { };
    audiomenu = callRustPackage pkgs "audiomenu" ./audiomenu/package.nix;
  };
in
{
  # Add scripts to overlay
  flake.overlays.scripts = _final: packages;

  # Add scripts to packages
  perSystem =
    { pkgs, ... }:
    {
      packages = packages pkgs;
    };
}
