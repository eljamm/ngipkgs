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
          submodule {
            options.module = mkOption {
              type = types.deferredModule;
              default = ./shell.nix;
            };
            options.activate = mkOption {
              type = types.package;
              default = config.shells.bash.activate; # TODO: more shells
            };
            projects = mkOption {
              type =
                with types;
                attrsOf (submodule {
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
          };
      };
      options.vm = mkOption {
        type = types.submodule {
          options.module = mkOption {
            type = types.deferredModule;
            default = ./vm.nix;
          };
          options.activate = mkOption {
            type = types.package;
            default = config.system.build.vm;
          };
        };
      };
    };
    default = { };
  };
}
