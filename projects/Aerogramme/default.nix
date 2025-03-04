{
  lib,
  pkgs,
  sources,
}@args:
{
  name = "Aerogramme";
  nixos = {
    # https://aerogramme.deuxfleurs.fr/documentation/cookbook/config/
    # https://aerogramme.deuxfleurs.fr/documentation/cookbook/service-manager/
    # derivation at https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/by-name/ae/aerogramme/package.nix
    modules.services = null;
    tests = null;
    examples = null;
  };
}
