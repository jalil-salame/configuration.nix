{ lib }:
{
  # Like mkEnableOption but defaults to true
  mkDisableOption =
    option:
    (lib.mkEnableOption option)
    // {
      default = true;
      example = false;
    };
  # A option that accepts an image (and shows it in the docs)
  mkImageOption =
    {
      description,
      url,
      sha256 ? "",
    }:
    lib.mkOption {
      inherit description;
      type = lib.types.path;
      default = builtins.fetchurl { inherit url sha256; };
      defaultText = lib.literalMD "![${description}](${url})";
    };
  # Like `lib.mkEnableOption` but default to disabled
  mkDisableOption =
    desc:
    lib.mkEnableOption desc
    // {
      default = true;
      example = false;
    };
  # Like `lib.mkPackageOption` but for a list of packages.
  mkExtraPackagesOption =
    name: defaultPkgsPath:
    let
      text = lib.strings.concatMapStringsSep " " (
        pkgPath: "pkgs." + (lib.strings.concatStringsSep "." pkgPath)
      ) defaultPkgsPath;
    in
    lib.mkOption {
      description = "Extra ${name} Packages.";
      type = lib.types.listOf lib.types.package;
      default = builtins.map (pkgPath: lib.attrsets.getAttrFromPath pkgPath pkgs) defaultPkgsPath;
      defaultText = lib.literalExpression "[ ${text} ]";
      example = [ ];
    };
}
