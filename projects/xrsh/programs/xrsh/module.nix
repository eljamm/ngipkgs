{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.xrsh;
in
{
  options.programs.xrsh = {
    enable = lib.mkEnableOption "enable xrsh";
    package = lib.mkPackageOption pkgs "xrsh" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
  };
}
