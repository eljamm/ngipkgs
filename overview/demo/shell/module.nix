{
  sources,
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    ;
in
{
  options.app-shell =
    with types;
    mkOption {
      type = attrsOf (submodule {
        options = {
          programs = mkOption {
            type = attrsOf package;
            description = "Set of programs that will be installed in the shell.";
            example = {
              geospatial = pkgs.qgis;
            };
            default = { };
          };
        };
      });
    };

  options.shells =
    with types;
    lib.mkOption {
      type = submodule {
        options = {
          bash.enable = mkOption {
            type = bool;
            default = true;
          };
          bash.activate = mkOption {
            type = nullOr package;
            default = null;
          };
        };
        config = lib.mkIf config.shells.bash.enable {
          bash.activate = import ./. {
            apps = lib.flatten (map (name: lib.attrValues name.programs) (lib.attrValues config.app-shell));
            inherit pkgs lib;
          };
        };
      };
      default = { };
    };
}
