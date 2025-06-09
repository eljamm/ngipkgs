{
  pkgs,
  options,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;

  nixOpts = options.nix.settings.type.getSubOptions { };

  nixConfig =
    cfg:
    with lib;
    let
      mkValueString =
        v:
        if v == null then
          ""
        else if isInt v then
          toString v
        else if isBool v then
          boolToString v
        else if isFloat v then
          floatToString v
        else if isList v then
          toString v
        else if isDerivation v then
          toString v
        else if builtins.isPath v then
          toString v
        else if isString v then
          v
        else if strings.isConvertibleWithToString v then
          toString v
        else
          abort "The nix conf value: ${toPretty { } v} can not be encoded";

      mkKeyValue = k: v: "${escape [ "=" ] k} = ${mkValueString v}";

      mkKeyValuePairs = attrs: concatStringsSep "\n" (mapAttrsToList mkKeyValue attrs);

      isExtra = key: hasPrefix "extra-" key;
    in
    pkgs.writeTextFile {
      name = "nix.conf";
      text = ''
        ${mkKeyValuePairs (filterAttrs (key: value: !(isExtra key)) cfg.settings)}
        ${mkKeyValuePairs (filterAttrs (key: value: isExtra key) cfg.settings)}
      '';
    };
in
{
  options = {
    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default = self: "NIX_CONFIG='${lib.trim (nixConfig self).text}'";
    };
    settings = mkOption {
      type =
        with types;
        submodule {
          options = {
            inherit (nixOpts)
              substituters
              trusted-public-keys
              ;
          };
        };
    };
  };
}
