{
  lib,
  pkgs,
  sources,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    ;

  nonEmtpyAttrs =
    elemType:
    with types;
    (
      (attrsOf elemType)
      // {
        name = "nonEmtpyAttrs";
        description = "non-empty attribute set";
        check = x: lib.isAttrs x && x != { };
      }
    );

  urlType =
    with types;
    submodule {
      options = {
        # link text
        text = mkOption { type = str; };
        # could be a hover/alternative text or simply a long-form description of a non-trivial resource
        description = mkOption {
          type = nullOr str;
          default = null;
        };
        # we may later want to do a fancy syntax check in a custom `typdef`
        url = mkOption { type = str; };
      };
    };

  binaryType =
    with types;
    submodule {
      options = {
        name = mkOption {
          type = nullOr str;
          default = null;
        };
        data = mkOption {
          type = nullOr (either path package);
          default = null;
        };
      };
    };

  exampleType =
    with types;
    submodule {
      options = {
        module = mkOption {
          type = moduleType;
        };
        description = mkOption {
          type = str;
        };
        tests = mkOption {
          type = nonEmtpyAttrs testType;
        };
        links = mkOption {
          type = attrsOf urlType;
          default = { };
        };
      };
    };

  # NixOS tests are modules that boil down to a derivation
  testType = with types; nullOr (either moduleType package);

  # TODO: make use of modular services https://github.com/NixOS/nixpkgs/pull/372170
  serviceType =
    with types;
    submodule {
      options = {
        name = mkOption {
          type = nullOr str;
          default = null;
        };
        module = mkOption {
          type = moduleType;
        };
        examples = mkOption {
          type = nullOr (attrsOf (nullOr exampleType));
          default = null;
        };
        extensions = mkOption {
          type = nullOr (attrsOf (nullOr pluginType));
          default = null;
        };
        links = mkOption {
          type = attrsOf urlType;
          default = { };
        };
      };
    };

  # TODO: port modular services to programs
  programType =
    with types;
    submodule {
      options = {
        name = mkOption {
          type = nullOr str;
          default = null;
        };
        module = mkOption {
          type = moduleType;
        };
        examples = mkOption {
          type = nullOr (attrsOf (nullOr exampleType));
          default = null;
        };
        extensions = mkOption {
          type = nullOr (attrsOf (nullOr pluginType));
          default = null;
        };
        links = mkOption {
          type = attrsOf urlType;
          default = { };
        };
      };
    };

  # TODO: plugins are actually component *extensions* that are of component-specific type,
  #       and which compose in application-specific ways defined in the application module.
  #       we can't express that with yants, but with the module system, which gives us a bit of dependent typing.
  #       this also means that there's no fundamental difference between programs and services,
  #       and even languages: libraries are just extensions of compilers.
  # TODO: implement this, now that we're using the module system
  pluginType = with types; anything;

  moduleType =
    with types;
    oneOf [
      path
      attrs
      (functionTo attrs)
    ];

  subgrantType =
    with types;
    submodule {
      options = lib.genAttrs [ "Commons" "Core" "Entrust" "Review" ] (
        name:
        mkOption {
          type = listOf str;
          default = [ ];
        }
      );
    };

  mkProject = name: value: {
    options.projects."${name}" = {
      name = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      metadata = mkOption {
        type =
          with types;
          nullOr (submodule {
            options = {
              summary = mkOption {
                type = nullOr str;
                default = null;
              };
              # TODO: convert all subgrants to `subgrantType`, remove listOf
              subgrants = mkOption {
                type = either (listOf str) subgrantType;
                default = null;
              };
              links = mkOption {
                type = attrsOf urlType;
                default = { };
              };
            };
          });
        default = null;
      };
      binary = mkOption {
        type = with types; attrsOf binaryType;
        default = { };
      };
      nixos = mkOption {
        type =
          with types;
          submodule {
            options = {
              modules.services = mkOption {
                type = nullOr (attrsOf (nullOr serviceType));
                default = null;
              };
              modules.programs = mkOption {
                type = nullOr (attrsOf (nullOr programType));
                default = null;
              };
              # An application component may have examples using it in isolation,
              # but examples may involve multiple application components.
              # Having examples at both layers allows us to trace coverage more easily.
              # If this tends to be too cumbersome for package authors and we find a way obtain coverage information programmatically,
              # we can still reduce granularity and move all examples to the application level.
              examples = mkOption {
                type = nullOr (attrsOf exampleType);
                default = null;
              };
              # TODO: Tests should really only be per example, in order to clarify that we care about tested examples more than merely tests.
              #       But reality is such that most NixOS tests aren't based on self-contained, minimal examples, or if they are they can't be extracted easily.
              #       Without this field, many applications will appear entirely untested although there's actually *some* assurance that *something* works.
              #       Eventually we want to move to documentable tests exclusively, and then remove this field, but this may take a very long time.
              tests = mkOption {
                type = nullOr (attrsOf testType);
                default = null;
              };
            };
          };
      };
    };

    config.projects."${name}" = value;
  };
in
{
  inherit mkProject;
}
