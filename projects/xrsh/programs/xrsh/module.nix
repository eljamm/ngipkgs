{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.xrsh;
  demoEnabled = lib.mkIf (cfg.enable && config.demo.enable);
in
{
  options.programs.xrsh = {
    enable = lib.mkEnableOption "enable xrsh";
    package = lib.mkPackageOption pkgs "xrsh" { };
    port = lib.mkOption {
      description = ''
        Port to serve xrsh on
      '';
      type = lib.types.nullOr lib.types.port;
      default = 8080;
    };
  };

  config =
    lib.mkIf cfg.enable {
      environment.systemPackages = [
        cfg.package
      ];
      environment.variables = {
        XRSH_PORT = toString cfg.port;
      };
    }
    // lib.mkIf demoEnabled {
      demo.shell.projects.xrsh = {
        programs = {
          xrsh = cfg.package;
        };
        env.XRSH_PORT = "8090";
      };
    };
}
