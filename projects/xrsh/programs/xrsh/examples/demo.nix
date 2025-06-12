{ lib, config, ... }:
let
  cfg = config.programs.xrsh;
in
{
  demo = {
    shell.projects.xrsh = {
      programs = {
        xrsh = cfg.package;
      };
      env.XRSH_PORT = "8090";
    };
  };

  render = {
    programs.xrsh.enable = true;
    programs.xrsh.port = 8090;
  };
}
