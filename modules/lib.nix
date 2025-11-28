{ lib }:
let
  inherit (lib) types;

  mkImageData' =
    pkgs:
    {
      description,
      url,
      sha256,
    }:
    {
      inherit description;
      type = types.path;
      default = pkgs.fetchurl { inherit url sha256; };
      defaultText = lib.literalMD "![${description}](${url})";
    };

  mkEnableData = description: builtins.removeAttrs (lib.mkEnableOption description) [ "_type" ];

  mkDisableData =
    description:
    mkEnableData description
    // {
      default = true;
      example = false;
    };
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
  mkImageOption' =
    pkgs:
    let
      mkImageData = mkImageData' pkgs;
    in
    attrs: lib.mkOption (mkImageData attrs);

  mkExtraPackagesOption' =
    pkgs: name: defaultPkgsPath:
    let
      pkgPathText = pkgPath: "pkgs.${lib.strings.concatStringsSep "." pkgPath}";
      text = lib.strings.concatMapStringsSep " " pkgPathText defaultPkgsPath;
    in
    lib.mkOption {
      description = "Extra ${name} Packages.";
      type = types.listOf types.package;
      default = builtins.map (pkgPath: lib.attrsets.getAttrFromPath pkgPath pkgs) defaultPkgsPath;
      defaultText = lib.literalExpression "[ ${text} ]";
      example = [ ];
    };

  fromOsOptions =
    attrs:
    let
      osConfig = attrs.osConfig or null;
      fromOs =
        attrPath: default: if osConfig == null then default else lib.attrByPath attrPath default osConfig;

      mkFromOsOption =
        {
          description,
          type,
          path,
          default,
          defaultText ? lib.options.renderOptionValue default,
          example ? null,
        }:
        let
          inherit (defaultText) _type text;
          pathText = lib.concatStringsSep "." path;
          formattedText =
            # Did we get an expression?
            if _type == "literalExpression" then
              lib.literalExpression "osConfig.${pathText} or ${text}"
            # Did we get some custom markdown?
            else if _type == "literalMD" then
              lib.literalMD "`osConfig.${pathText}` or ${text}"
            # Not implemented
            else
              builtins.throw "Unexpected type ${_type}";
        in
        lib.mkOption {
          inherit description type example;
          default = fromOs path default;
          defaultText = formattedText;
        };

      mkFromConfigOption = { path, ... }@args: mkFromOsOption (args // { path = [ "jconfig" ] ++ path; });
    in
    {
      inherit
        fromOs
        mkFromOsOption
        mkFromConfigOption
        ;

      mkFromConfigImageOption' =
        pkgs:
        let
          mkImageData = mkImageData' pkgs;
        in
        { path, ... }@attrs:
        mkFromConfigOption (mkImageData (builtins.removeAttrs attrs [ "path" ]) // { inherit path; });

      mkFromConfigEnableOption =
        description: path: mkFromConfigOption (mkEnableData description // { inherit path; });

      mkFromConfigDisableOption =
        description: path: mkFromConfigOption (mkDisableData description // { inherit path; });
    };
}
