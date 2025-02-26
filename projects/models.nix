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
    struct
    drv
    ;

  # TODO: use struct
  moduleType = string;

  exampleType = struct "example" {
    description = option string;
    path = option string;
    documentation = option string;
  };

  optionalStruct = attrs: option (struct attrs);
in
rec {
  project = struct {
    name = string;
    metadata = optionalStruct {
      summary = option string;
      subgrants = list string;
    };
    nixos = struct "nixos" {
      examples = option (attrs exampleType);
      tests = option (attrs (option drv));
      modules = struct "modules" {
        programs = option (attrs (option moduleType));
        services = option (attrs (option moduleType));
      };
    };
  };

  example = project {
    name = "";
    nixos = {
      examples = { };
      tests = {
        basic = null;
      };
      modules = {
        # Attributes not defined in the data structure are not allowed.
        # Uncommenting this will raise an error
        #hello = { };

        programs = {
          # Set to `null`: needed, but not available
          foobar = null;

          # Not set: not needed
        };
      };
    };
  };
}
