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

  urlType = struct "URL" {
    # link text
    text = string;
    # could be a hover/alternative text or simply a long-form description of a non-trivial resource
    description = option string;
    # we may later want to do a fancy syntax check in a custom `typdef`
    link = string;
  };

  # TODO: see https://github.com/ngi-nix/ngipkgs/pull/507#issuecomment-2696587318
  libraryType = any;
  pluginType = any;

  moduleType = eitherN absPath function attrs;

  programType = struct "program" {
    name = option string;
    module = moduleType;
    references = optionalStruct {
      build = option urlType;
      tests = option urlType;
    };
    examples = nonEmtpyAttrs (option exampleType);
    plugins = optionalAttrs (option pluginType);
  };

  serviceType = struct "service" {
    name = option string;
    module = moduleType;
    references = optionalStruct {
      config = option urlType;
    };
    examples = nonEmtpyAttrs (option exampleType);
    plugins = optionalAttrs (option pluginType);
  };

  exampleType = struct "example" {
    description = string;
    module = moduleType;
    references = optionalAttrs urlType;
    tests = nonEmtpyAttrs testType;
  };

  # NixOS tests are modules that boil down to a derivation
  testType = option (either moduleType drv);

  optionalStruct = set: option (struct set);
  optionalAttrs = set: option (attrs set);
  nonEmtpyAttrs = t: restrict "non-empty attribute set" (a: a != { }) (attrs t);
  absPath = restrict "absolute path" (p: lib.pathExists p) (either path string);
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
      tests = option (attrs testType);
      modules = struct "modules" {
        programs = optionalAttrs (option programType);
        services = option (either (attrs (option serviceType)) function);
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
          module = { ... }: { };
          references = {
            website = {
              text = "FooBar Documentation";
              link = "https://foo.bar/docs";
            };
          };
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
