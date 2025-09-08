{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Oblivious Pseudo-random Functions (OPRFs) and Threshold constructions implementations";
    subgrants = [
      "OpaqueSphinxServer"
      "OpaqueStore-Sphinx2.0"
      "ThresholdOPRF"
    ];
  };

  nixos.modules.programs = {
    pwdsphinx = {
      module = ./programs/pwdsphinx/module.nix;
      examples."Enable pwdsphinx" = {
        module = ./programs/pwdsphinx/examples/basic.nix;
        tests.basic.module = null;
      };
    };
  };

  # pwdsphinx needs a module
  nixos.modules.services.ThresholdOPRF.module = null;

  nixos.examples."Development shell (C)" = {
    module = ./libraries/shells/c.nix;
    tests.basic.module = null;
  };
  nixos.examples."Development shell (Python)" = {
    module = ./libraries/shells/python.nix;
    tests.basic.module = null;
  };
}
