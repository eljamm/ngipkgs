{ pkgs, ... }@args:
{
  # TODO: put these in modules
  # packages = {
  #   inherit (pkgs)
  #     atomic-server
  #     atomic-browser
  #     atomic-cli
  #     ;
  # };
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
