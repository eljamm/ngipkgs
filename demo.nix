{
  ngipkgs ? import ./. { },
}:
ngipkgs.demo-shell (
  { config, ... }:
  {
    programs.xrsh.enable = true;
    programs.xrsh.port = 8090;
  }
)
