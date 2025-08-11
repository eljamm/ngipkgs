{
  lib,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    ;

in
rec {
  metadata =
    with types;
    submodule {
      options = {
        summary = mkOption {
          type = nullOr str;
          default = null;
        };
        # TODO: convert all subgrants to `subgrant`, remove listOf
        subgrants = mkOption {
          type = either (listOf str) subgrant;
          default = null;
        };
        links = mkOption {
          type = attrsOf link;
          default = { };
        };
      };
    };

  subgrant =
    with types;
    submodule {
      options =
        lib.genAttrs
          [
            "Commons"
            "Core"
            "Entrust"
            "Review"
          ]
          (
            name:
            mkOption {
              description = "subgrants under the ${name} fund";
              type = listOf str;
              default = [ ];
            }
          );
    };

  link =
    with types;
    submodule (
      { name, ... }:
      {
        options = {
          text = mkOption {
            description = "link text";
            type = str;
            default = name;
          };
          description = mkOption {
            description = "long-form description of the linked resource";
            type = nullOr str;
            default = null;
          };
          # TODO: add syntax checking
          url = mkOption {
            type = str;
          };
        };
      }
    );

  binary =
    with types;
    submodule (
      { name, ... }:
      {
        options = {
          name = mkOption {
            type = str;
            default = name;
          };
          data = mkOption {
            type = nullOr (either path package);
            default = null;
          };
        };
      }
    );

  /**
      The following information applies to both services and programs.

      :::{.example}
      ```nix
      nixos.modules.foobar.examples.basic = {
        module = ./programs/foobar/examples/basic.nix;
        description = "Basic configuration example for foobar";
        tests.foobar-basic.module = import ./programs/foobar/tests/basic.nix args;
      };
      ```
      :::

      > [!NOTE]
      > Each program must include at least one example, so users get an idea of what to do with it.

      For modules that reside in NixOS, use:

      ```nix
      {
        module = lib.moduleLocFromOptionString "programs.PROGRAM_NAME";
      }
      ```

      If you want to extend such modules, you can import them in a new module:

      ```nix
      {
        module = ./module.nix;
      }
      ```

      Where `module.nix` contains:

      ```nix
      { lib, ... }:
      {
        imports = [
          (lib.moduleLocFromOptionString "programs.PROGRAM_NAME")
        ];

        options.programs.PROGRAM_NAME = {
          extra-option = lib.mkEnableOption "extra option";
        };
      }
      ```
  */
  # TODO: port modular services to programs
  program =
    with types;
    submodule (
      { name, ... }:
      {
        options = {
          name = mkOption {
            type = str;
            default = name;
          };
          module = mkOption {
            type = nullOr deferredModule;
            description = ''
              Contains the path to the NixOS module for the program.
            '';
          };
          examples = mkOption {
            type = attrsOf example;
            description = ''
              Configurations that illustrate how to set up the program.
            '';
            default = { };
          };
          links = mkOption {
            type = attrsOf link;
            description = ''
              Links to documentation or resources that may help building, configuring and testing the program.
            '';
            example = {
              usage = {
                text = "Usage examples";
                url = "https://docs.foobar.com/quickstart";
              };
              build = {
                text = "Build from source";
                url = "https://docs.foobar.com/dev";
              };
            };
            default = { };
          };
          extensions = mkOption {
            type = attrsOf (nullOr plugin);
            default = { };
          };
        };
      }
    );

  # TODO: make use of modular services https://github.com/NixOS/nixpkgs/pull/372170
  service =
    with types;
    submodule (
      { name, ... }:
      {
        options = {
          name = mkOption {
            type = str;
            default = name;
          };
          module = mkOption {
            type = nullOr deferredModule;
          };
          examples = mkOption {
            type = attrsOf example;
            default = { };
          };
          extensions = mkOption {
            type = nullOr (attrsOf (nullOr plugin));
            default = null;
          };
          links = mkOption {
            type = attrsOf link;
            default = { };
          };
        };
      }
    );

  # TODO: plugins are actually component *extensions* that are of component-specific type,
  #       and which compose in application-specific ways defined in the application module.
  #       this also means that there's no fundamental difference between programs and services,
  #       and even languages: libraries are just extensions of compilers.
  # TODO: implement this, now that we're using the module system
  plugin = with types; anything;

  example =
    with types;
    submodule (
      { name, ... }:
      {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
          };
          module = mkOption {
            description = "the example must be a NixOS module in a file";
            type = with types; nullOr path;
          };
          description = mkOption {
            description = "description of the example, ideally with further instructions on how to use it";
            type = with types; nullOr str;
            default = null;
          };
          tests = mkOption {
            description = "at least one test for the example";
            type = types.attrsOf test;
            default = { };
          };
          links = mkOption {
            description = "links to related resources";
            type = types.attrsOf link;
            default = { };
          };
        };
      }
    );

  /**
    :::{.example}

    Replace `TYPE` with either `vm` or `shell`.
    This indicates the preferred environment for running the application: NixOS VM or a terminal shell.

    ```nix
    nixos.demo.TYPE = {
      module = ./path/to/application/configuration.nix;
      module-demo = ./path/to/demo/only/configuration.nix;
      description = ''
        Instructions for using the application

        1.
        2.
        3.
      '';
      tests = { };
    };
    ```

    The `module` option is meant for setting up the application, while `demo-config` is for demo-specific things, like [demo-shell](./overview/demo/shell.nix) configuration.
    :::
  */
  demo = types.submodule {
    options = {
      inherit (example.getSubOptions { })
        module
        tests
        description
        links
        ;
      problem = mkOption {
        type = types.nullOr problem;
        default = null;
        example = {
          problem.broken = {
            reason = "Does not work as intended. Needs fixing.";
          };
        };
      };
    };
  };

  problem = types.attrTag {
    broken = mkOption {
      type = types.submodule {
        options.reason = mkOption {
          type = types.str;
        };
      };
    };
  };

  /**
    The test module can be one of:

      - null:
        Test is needed, but not available.

      - NixOS module:
        Will be evaluated to a NixOS test derivation.

      - Package:
        Derivation (e.g. nixosTests.foobar), which can be used directly.
  */
  test = types.submodule {
    options = {
      module = mkOption {
        type = with types; nullOr (either deferredModule package);
        default = null;
      };
      problem = mkOption {
        type = types.nullOr problem;
        default = null;
      };
    };
  };

  /**
    NGI-funded software application.
  */
  project =
    { name, ... }:
    {
      options = {
        name = mkOption {
          type = types.str;
          default = name;
        };
        metadata = mkOption {
          type = types.nullOr metadata;
          default = null;
        };
        binary = mkOption {
          type = types.attrsOf binary;
          default = { };
        };
        nixos = mkOption {
          type =
            with types;
            submodule {
              options = {
                modules = {
                  /**
                    Software that can be run in the shell.

                    :::{.example}

                    ```nix
                    nixos.modules.programs.foobar = {
                      module = ./programs/foobar/module.nix;
                      examples.basic = {
                        module = ./programs/foobar/examples/basic.nix;
                        description = "Basic configuration example for foobar";
                        tests.basic.module = import ./programs/foobar/tests/basic.nix args;
                      };
                    };
                    ```

                    :::
                  */
                  programs = mkOption {
                    type = attrsOf program;
                    default = { };
                  };

                  /**
                    Software that runs as a background process.

                    TODO
                  */
                  services = mkOption {
                    type = attrsOf service;
                    default = { };
                  };
                };
                /**
                  Practical demonstration of an application.

                  It provides an easy way for users to test its functionality and assess its suitability for their use cases.
                */
                demo = mkOption {
                  type = nullOr (attrTag {
                    vm = mkOption { type = demo; };
                    shell = mkOption { type = demo; };
                  });
                  default = null;
                };
                /**
                  Configuration of an existing application module that illustrates how to use it.

                  An application component may have examples using it in isolation,
                  but examples may involve multiple application components.
                  Having examples at both layers allows us to trace coverage more easily.
                  If this tends to be too cumbersome for package authors and we find a way obtain coverage information programmatically,
                  we can still reduce granularity and move all examples to the application level.
                */
                examples = mkOption {
                  type = attrsOf example;
                  default = { };
                };
                # TODO: Tests should really only be per example, in order to clarify that we care about tested examples more than merely tests.
                #       But reality is such that most NixOS tests aren't based on self-contained, minimal examples, or if they are they can't be extracted easily.
                #       Without this field, many applications will appear entirely untested although there's actually *some* assurance that *something* works.
                #       Eventually we want to move to documentable tests exclusively, and then remove this field, but this may take a very long time.
                tests = mkOption {
                  type = attrsOf test;
                  default = { };
                };
              };
            };
        };
      };
    };

  projects = mkOption {
    type = with types; attrsOf (submodule project);
  };
}
