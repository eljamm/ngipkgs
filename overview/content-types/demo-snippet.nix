{
  lib,
  config,
  pkgs,
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
    demo-file = mkOption {
      type = types.path;
      default = pkgs.writeText "default.nix" config.snippet-text;
    };
    example-text = mkOption {
      type = types.str;
    };
  };

  config.filepath = config.demo-file;
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
