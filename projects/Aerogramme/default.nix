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
    modules.services = null;
    tests = null;
    examples = null;
  };
}
