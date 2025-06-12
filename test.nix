{
  ngipkgs ? import ./. { },
}:
ngipkgs.demo-shell {
  programs.xrsh.enable = true;
  programs.xrsh.port = 8090;
}
