{
  lib,
  pkgs,
  sources,
}:
let
  yants = import sources.yants { };

  inherit (yants)
    string
    list
    option
    attrs
    enum
    either
    ;
in
rec {
  project =
    project: {
      name = string name;
      metadata = {
        summary = option (string project.metadata.summary);
        subgrants = list string project.metadata.subgrants;
      };
      # TODO: somehow express that "not set" means "not needed" and "set to `null`" means "needed but not available".
      nixos.modules.programs = option attrs (option (/* TODO: a module */)) (
        if project ? nixos.modules.programs then project.nixos.modules.programs else null
        );
        nixos.modules.services = option attrs (option (/* TODO: a module */)) (
        if project ? nixos.modules.programs then project.nixos.modules.programs else null
        );
      nixos.examples = attrs (option /* attrs: description, path, documentation */) project.nixos.examples;
      nixos.tests = attrs (option derivation) project.nixos.tests;
    };

  example = project {
    name = "";
    metadata = {
      summary = "";
      websites = {
        repo = "";
        docs = "";
      };
    };
  };
}
