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
  options.demo = mkOption {
    type = types.submodule {
      options.enable = lib.mkEnableOption "demo";
      options.shell = mkOption {
        type =
          with types;
          attrsOf (submodule {
            options.module = mkOption { type = types.deferredModule; };
            options.programs = mkOption {
              type = attrsOf package;
              description = "Set of programs that will be installed in the shell.";
              example = {
                embedded = pkgs.icestudio;
                messaging = pkgs.briar-desktop;
              };
              default = { };
            };
            options.env = mkOption {
              type = attrsOf str;
              description = "Set of environment variables that will be passed to the shell.";
              example = {
                XRSH_PORT = "9090";
              };
              default = { };
            };
          });
      };
      options.vm = mkOption {
        type =
          with types;
          attrsOf (submodule {
            options.module = mkOption { type = types.deferredModule; };
          });
      };
    };
    default = { };
  };
}
