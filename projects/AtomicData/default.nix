{ pkgs, ... }@args:
{
  name = "AtomicData";
  nixos = {
    modules.services.atomic-server = {
      module = ./service.nix;
      examples.base = {
        module = ./example.nix;
        description = "Basic configuration, mainly used for testing purposes.";
        tests.base = import ./test.nix args;
      };
    };
  };
}
