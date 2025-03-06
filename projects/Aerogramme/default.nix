{
  lib,
  pkgs,
  sources,
}@args:
{
  nixos = {
    modules.services.aerogramme = {
      references = {
        config = {
          text = "Configuration reference";
          url = "https://aerogramme.deuxfleurs.fr/documentation/reference/config/";
        };
        service-manager = {
          text = "Using with service managers";
          url = "https://aerogramme.deuxfleurs.fr/documentation/cookbook/service-manager/";
        };
        nixpkgs = {
          text = "Nixpkgs derivation";
          url = "https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/by-name/ae/aerogramme/package.nix";
        };
      };
      module =
        { lib, pkgs, ... }:
        {
          options = {
            enable = lib.mkEnableOption "Aerogramme";
            package = lib.mkPackageOption pkgs "aerogramme" { };
          };
          # TODO: add a service definition
          meta.broken = true;
        };
    };
    tests = null;
    examples = null;
  };
}
