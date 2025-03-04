{
  lib,
  pkgs,
  sources,
  yants ? import sources.yants { inherit lib; },
}:
let
  inherit (yants)
    string
    list
    option
    attrs
    either
    struct
    drv
    path
    restrict
    function
    any
    ;

  programType = struct "program" {
    name = option string;
    module = either path function;
    documentation = optionalStruct {
      build = option string;
      tests = option string;
    };
    examples = nonEmtpyAttrs (option exampleType);
  };

  serviceType = struct "service" {
    name = option string;
    module = either path function;
    documentation = optionalStruct {
      config = option string;
    };
    examples = nonEmtpyAttrs (option exampleType);
  };

  exampleType = struct "example" {
    description = string;
    path = either string path;
    documentation = option string;
    tests = nonEmtpyAttrs drv;
  };

  optionalStruct = attrs: option (struct attrs);
  nonEmtpyAttrs = t: restrict "non-empty-attrs" (a: a != { }) (attrs t);
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
      tests = option (attrs (option (either drv (attrs any))));
      modules = struct "modules" {
        programs = option (attrs (option programType));
        services = option (attrs (option serviceType));
      };
    };
  };

  example = project {
    name = "foobar";
    nixos = rec {
      examples = {
        foobar-cli = {
          description = ''
            This is how you can run `foobar` in the terminal.
          '';
          path = "";
          documentation = "https://foo.bar/docs";
          tests = {
            # Each example must have at least one test.
            # If the line below is commented out, an error will be raised.
            inherit (tests) foobar-cli;
          };
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

          foobar-cli = {
            name = "foobar-cli";
            module =
              { lib, ... }:
              {
                enable = lib.mkEnableOption "foobar CLI";
              };
            # Each program must have at least one example.
            # Examples can be null to indicate that they're needed.
            examples = {
              inherit (examples) foobar-cli;

              # needed, not available
              foobar-tui = null;
            };
          };

          # Not set: not needed
        };
      };
    };
  };
}
