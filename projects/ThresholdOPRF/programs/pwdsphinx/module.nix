{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.pwdsphinx;
in
{
  options.programs.pwdsphinx = {
    enable = lib.mkEnableOption "pwdsphinx";
    package = lib.mkPackageOption pkgs "pwdsphinx" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
