{
  ngipkgs ? import (fetchTarball "https://github.com/ngi-nix/ngipkgs/tarball/main") { },
  pkgs ? ngipkgs.pkgs,
}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    libopaque
    liboprf
  ];
}
