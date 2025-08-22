{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = ''
      Keyoxide is a privacy-friendly tool to create and verify decentralized online identities.
    '';
    subgrants = [
      "Keyoxide"
      "Keyoxide-Mobile"
      "Keyoxide-PKO"
      "Keyoxide-signatures"
    ];
  };
  nixos.modules.services.keyoxide = ./keyoxide-web;
  nixos.modules.programs.keyoxide-cli = ./keyoxide-cli;
}
