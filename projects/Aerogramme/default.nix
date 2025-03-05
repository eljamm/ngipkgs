{
  lib,
  pkgs,
  sources,
}@args:
{
  nixos = {
    # https://aerogramme.deuxfleurs.fr/documentation/cookbook/config/
    # https://aerogramme.deuxfleurs.fr/documentation/cookbook/service-manager/
    # derivation at https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/by-name/ae/aerogramme/package.nix
    modules.services =
      { lib, pkgs, ... }:
      {
        options = {
          enable = lib.mkEnableOption "Aerogramme";
          package = lib.mkPackageOption pkgs "aerogramme" { };
        };
        # TODO: add a service definition
        meta.broken = true;
      };
    tests = null;
    examples = null;
  };
}
