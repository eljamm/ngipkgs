{
  lib,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    ;

  types' = {
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
            type = with types; nullOr (either (listOf str) types'.subgrant);
            default = null;
          };
          links = mkOption {
            type = attrsOf types'.link;
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
        Software that runs in the shell.

        :::{.example}
        ```nix
        nixos.modules.programs.PROGRAM_NAME = {
          module = ./path/to/module.nix;
          examples."Enable foobar" = {
            module = ./path/to/examples/basic.nix;
            description = "Basic configuration example for foobar";
            tests.basic.module = import ./path/to/tests/basic.nix args;
          };
        };
        ```
        :::

        ::: {.note}
        Each program must include at least one example, so users get an idea of what to do with it.
        :::

        After implementing the program, run the [checks](#checks) to make sure that everything is correct.
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
              '';
            };
            examples = mkOption {
              type = attrsOf types'.example;
              description = ''
                Configurations that illustrate how to set up the program.
              '';
              example = lib.literalExpression ''
                nixos.modules.programs.examples."Enable foobar" = {
                  module = ./programs/foobar/examples/basic.nix;
                  description = "Basic configuration example for foobar";
                  tests.foobar-basic.module = import ./programs/foobar/tests/basic.nix args;
                };
              '';
              default = { };
            };
            links = mkOption {
              type = attrsOf types'.link;
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
              type = attrsOf (nullOr types'.plugin);
              default = { };
            };
          };
        }
      );

    /**
        Software that runs as a background process.

        :::{.example}
        ```nix
        nixos.modules.services.SERVICE_NAME = {
          module = ./path/to/module.nix;
          examples."Enable foobar" = {
            module = ./path/to/examples/basic.nix;
            description = "Basic configuration example for foobar";
            tests.basic.module = import ./path/to/tests/basic.nix args;
          };
        };
        ```
        :::

        ::: {.note}
        Each service must include at least one example, so users get an idea of what to do with it.
        :::

        After implementing the service, run the [checks](#checks) to make sure that everything is correct.
    */
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
              description = ''
                Contains the path to the NixOS module for the service.

                For modules that reside in NixOS, use:

                ```nix
                {
                  module = lib.moduleLocFromOptionString "services.SERVICE_NAME";
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
                    (lib.moduleLocFromOptionString "services.SERVICE_NAME")
                  ];

                  options.services.SERVICE_NAME = {
                    extra-option = lib.mkEnableOption "extra option";
                  };
                }
                ```
              '';
            };
            examples = mkOption {
              type = attrsOf types'.example;
              default = { };
            };
            extensions = mkOption {
              type = nullOr (attrsOf (nullOr types'.plugin));
              default = null;
            };
            links = mkOption {
              type = attrsOf types'.link;
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
              description = ''
                File path to a NixOS module that contains the application configuration
              '';
              type = with types; nullOr path;
            };
            description = mkOption {
              description = "description of the example, ideally with further instructions on how to use it";
              type = with types; nullOr str;
              default = null;
            };
            tests = mkOption {
              description = "at least one test for the example";
              type = types.attrsOf types'.test;
              default = { };
            };
            links = mkOption {
              description = "links to related resources";
              type = types.attrsOf types'.link;
              default = { };
            };
          };
        }
      );

    /**
      Practical demonstration of an application.

      It provides an easy way for users to test its functionality and assess its suitability for their use cases.

      :::{.example}
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
      :::

      - Replace `TYPE` with either `vm` or `shell`.
      This indicates the preferred environment for running the application: NixOS VM or terminal shell.

      - Use `module` for the application configuration and `module-demo` for demo-specific things, like [demo-shell](./overview/demo/shell.nix).
      For the latter, it could be something like:

      ::: {.example}
      ```nix
      # ./path/to/demo/only/configuration.nix
      {
        lib,
        config,
        ...
      }:
      let
        cfg = config.programs.foobar;
      in
      {
        config = lib.mkIf cfg.enable {
          demo-shell = {
            programs.foobar = cfg.package;
            env.TEST_PORT = toString cfg.port;
          };
        };
      }
      ```
      :::

      After implementing the demo, run the [checks](#checks) to make sure that everything is correct.
    */
    demo = types.submodule (
      { name, ... }:
      {
        options = {
          inherit (types'.example.getSubOptions { })
            module
            tests
            description
            links
            ;
          module-demo = mkOption {
            description = ''
              NixOS module that contains everything needed to use an application demo conveniently
            '';
            type = types.deferredModuleWith {
              staticModules =
                lib.optionals (name == "vm") [
                  ../overview/demo/vm
                ]
                ++ lib.optionals (name == "shell") [
                  ../overview/demo/shell.nix
                ];
            };
            default = { };
          };
          problem = mkOption {
            type = types.nullOr types'.problem;
            default = null;
            example = {
              problem.broken = {
                reason = "Does not work as intended. Needs fixing.";
              };
            };
          };
        };
      }
    );

    problem = types.attrTag {
      broken = mkOption {
        type = types.submodule {
          options.reason = mkOption {
            type = types.str;
          };
        };
      };
    };

    test = types.submodule {
      options = {
        module = mkOption {
          type = with types; nullOr (either deferredModule package);
          default = null;
        };
        problem = mkOption {
          type = types.nullOr types'.problem;
          default = null;
        };
      };
    };

    /**
        NGI-funded software application.

        ### Checks

        After implementing one of a project's components:

        1. Verify that its checks are successful:

          ```shellSession
          nix-build -A checks.PROJECT_NAME
          ```

        1. Run the tests, if they exist, and make sure they pass:

          ```shellSession
          nix-build -A projects.PROJECT_NAME.nixos.tests.TEST_NAME
          ```

        1. [Run the overview locally](#running-and-testing-the-overview-locally), navigate to the project page and make sure that the program options and examples shows up correctly

        1. [Make a Pull Request on GitHub](#how-to-create-pull-requests-to-ngipkgs)
    */
    projects = mkOption {
      type =
        with types;
        attrsOf (
          submodule (
            { name, ... }:
            {
              options = {
                name = mkOption {
                  type = str;
                  default = name;
                };
                metadata = mkOption {
                  type = with types; nullOr types'.metadata;
                  default = null;
                };
                binary = mkOption {
                  type = with types; attrsOf types'.binary;
                  default = { };
                };
                nixos = mkOption {
                  type =
                    with types;
                    submodule {
                      options = {
                        modules = {
                          programs = mkOption {
                            type = attrsOf types'.program;
                            description = "Software that can be run in the shell";
                            example = lib.literalExpression ''
                              nixos.modules.programs.foobar = {
                                module = ./programs/foobar/module.nix;
                                examples.basic = {
                                  module = ./programs/foobar/examples/basic.nix;
                                  description = "Basic configuration example for foobar";
                                  tests.basic.module = import ./programs/foobar/tests/basic.nix args;
                                };
                              };
                            '';
                            default = { };
                          };
                          services = mkOption {
                            type = attrsOf types'.service;
                            description = "Software that runs as a background process";
                            default = { };
                          };
                        };
                        demo = mkOption {
                          type = nullOr (attrTag {
                            vm = mkOption { type = types'.demo; };
                            shell = mkOption { type = types'.demo; };
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
                          type = attrsOf types'.example;
                          description = "A configuration of an existing application module that illustrates how to use it";
                          default = { };
                        };
                        # TODO: Tests should really only be per example, in order to clarify that we care about tested examples more than merely tests.
                        #       But reality is such that most NixOS tests aren't based on self-contained, minimal examples, or if they are they can't be extracted easily.
                        #       Without this field, many applications will appear entirely untested although there's actually *some* assurance that *something* works.
                        #       Eventually we want to move to documentable tests exclusively, and then remove this field, but this may take a very long time.
                        tests = mkOption {
                          type = attrsOf types'.test;
                          default = { };
                        };
                      };
                    };
                };
              };
            }
          )
        );
    };
  };
in
types'
