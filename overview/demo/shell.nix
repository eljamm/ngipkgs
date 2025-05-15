{
  sources,
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
      type = attrsOf (
        submodule (
          { name, config, ... }:
          {
            options = {
              programs = mkOption {
                type = attrsOf package;
                description = "Set of programs that will be installed in the shell.";
                example = {
                  geospatial = pkgs.qgis;
                };
                default = { };
              };
              libraries = mkOption {
                type = attrsOf package;
                description = "Set of libraries that will be installed in the shell.";
                example = {
                  zlib = pkgs.zlib;
                };
                default = { };
              };
              shells = lib.mkOption {
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
                    bash.activate = import "${sources.app-shell}/app-shell.nix" {
                      apps = lib.attrValues config.programs;
                      libs = lib.attrValues config.libraries;
                      inherit pkgs;
                    };
                  };
                };
                default = { };
              };
            };
          }
        )
      );
    };
}
