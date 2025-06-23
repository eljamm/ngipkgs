{
  lib,
  name,
  config,
  ...
}:
let
  inherit (lib) mkOption types;

  cfg = config.demo-snippet;
in
{
  imports = [ ./code-snippet.nix ];

  options = {
    demo-type = mkOption {
      type = types.str;
      default = name;
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
    ngipkgs.demo-${cfg.demo-type} (
      ${toString (lib.intersperse "\n " (lib.splitString "\n" cfg.example-text))}
    )
  '';
}
