{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  imports = [ ./code-snippet.nix ];

  options = {
    demo-type = mkOption {
      type = types.str;
    };
    example-text = mkOption {
      type = types.str;
    };
  };

  config.snippet-text = ''
    # default.nix
    {
      ngipkgs ? import (fetchTarball "https://github.com/ngi-nix/ngipkgs/tarball/main") { },
    }:
    ngipkgs.demo-${config.demo-type} (
      ${toString (lib.intersperse "\n " (lib.splitString "\n" config.example-text))}
    )
  '';
}
