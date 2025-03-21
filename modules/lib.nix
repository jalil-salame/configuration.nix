{ lib }:
let
  inherit (lib) types;
in
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
      type = types.path;
      default = builtins.fetchurl { inherit url sha256; };
      defaultText = lib.literalMD "![${description}](${url})";
    };
}
