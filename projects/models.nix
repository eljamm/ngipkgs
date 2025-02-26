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
    path
    ;

  # TODO: use struct
  moduleType = string;

  exampleType = struct "example" {
    description = option string; # TODO: should this be non-optional?
    path = either string path;
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
    name = "foobar";
    nixos = {
      examples = {
        foobar-cli = {
          description = ''
            This is how you can run `foobar` in the terminal.
          '';
          path = "";
          documentation = "";
        };
      };
      tests = {
        # Set to `null`: needed, but not available
        basic = null;

        # Needs to be a derivation. Error raised otherwise.
        #simple = "This will fail.";

        foobar-cli = derivation {
          name = "myname";
          builder = "mybuilder";
          system = "mysystem";
        };
      };
      modules = {
        # Attributes not defined in the data structure are not allowed.
        # Uncommenting the line below will raise an error.
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
