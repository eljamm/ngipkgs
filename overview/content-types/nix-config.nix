{
  lib,
  config,
  options,
  nixpkgs,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;

  nixOpts = options.nix.settings.type.getSubOptions { };
  nix-module = import "${nixpkgs}/nixos/modules/config/nix.nix" { inherit config lib pkgs; };
in
{
  options = {
    inherit (nix-module.options) nix;

    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default =
        self:
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
        "NIX_CONFIG='${lib.trim ''
          ${mkKeyValuePairs (filterAttrs (key: value: !(isExtra key)) self.settings)}
          ${mkKeyValuePairs (filterAttrs (key: value: isExtra key) self.settings)}
        ''}'";
    };
    settings = mkOption {
      type = types.submodule {
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
