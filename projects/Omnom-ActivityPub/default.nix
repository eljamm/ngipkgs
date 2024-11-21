{
  pkgs,
  sources,
  ...
}: {
  packages = {
    inherit (pkgs) omnom;
  };
  nixos.examples = {
    base = {
      path = ./example.nix;
      description = "Basic Omnom configuration, mainly used for testing purposes.";
    };
  };
  nixos.modules.services.omnom = "${sources.inputs.nixpkgs}/nixos/modules/services/misc/omnom.nix";
  nixos.tests = null;
}
