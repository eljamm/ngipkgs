{
  lib,
  pkgs,
  sources,
  system,

  nixos-modules,
  ...
}@args:
let
  inherit (builtins)
    elem
    readDir
    trace
    ;

  inherit (lib.attrsets)
    concatMapAttrs
    mapAttrs
    ;

  types = import ./types.nix { inherit lib; };

  baseDirectory = ./.;

  projectDirectories =
    let
      names =
        name: type:
        if type == "directory" then
          { ${name} = baseDirectory + "/${name}"; }
        # nothing else should be kept in this directory reserved for projects
        else
          assert elem name allowedFiles;
          { };
      allowedFiles = [
        "README.md"
        "default.nix"
        "tests.nix"
        "tests-2.nix"
        "types.nix"
      ];
    in
    # TODO: use fileset and filter for `gitTracked` files
    concatMapAttrs names (readDir baseDirectory);
in
rec {
  project-names = lib.attrNames projectDirectories;

  raw-projects = {
    options.projects = types.options.projects;
    config.projects = mapAttrs (name: directory: import directory args) projectDirectories;
  };

  eval-projects = lib.evalModules {
    modules = [
      raw-projects
    ];
    specialArgs.modulesPath = "${sources.inputs.nixpkgs}/nixos/modules";
  };

  projects = eval-projects.config.projects;

  # Force recursive evaluation for all projects
  checks = lib.mapAttrs (
    name: value: pkgs.writeText "${name}-eval-check" (lib.strings.toJSON value)
  ) (lib.forceEvalRecursive projects);

  optionsDoc = pkgs.nixosOptionsDoc {
    inherit
      (lib.evalModules {
        modules = [
          {
            # Don't check because NixOS options are not included.
            # See comment in NixOS' `noCheckForDocsModule`.
            config._module.check = false;

            config.nixpkgs.hostPlatform = system;
            config._module.args.pkgs = pkgs;

            imports = lib.pipe nixos-modules [
              (lib.filterAttrs (_: value: lib.isAttrs value))
              (lib.mapAttrsToList (name: value: lib.attrValues value))
              (lib.flatten)
            ];
          }
        ];
        specialArgs.modulesPath = "${sources.inputs.nixpkgs}/nixos/modules";
      })
      options
      ;
  };

  metadata = lib.mapAttrs (name: project: project.metadata) projects;

  raw-demos = lib.pipe projects [
    (lib.mapAttrs (_: value: value.nixos.demo.vm or value.nixos.demo.shell or null))
    (lib.filterAttrs (_: value: value != null))
  ];

  demo-modules = lib.pipe raw-demos [
    (lib.mapAttrsToList (_: value: value.module-demo.imports))
    (lib.flatten)
  ];

  modules = lib.mapAttrs (name: project: {
    services = lib.pipe project.nixos.modules.services [
      (lib.mapAttrs (name: value: value.module))
      (lib.filterAttrs (name: value: value != null))
    ];
    programs = lib.pipe project.nixos.modules.programs [
      (lib.mapAttrs (name: value: value.module))
      (lib.filterAttrs (name: value: value != null))
    ];
  }) projects;

  examples = lib.mapAttrs (name: project: {
    services = lib.pipe project.nixos.modules.services [
      (lib.mapAttrs (name: value: value.examples))
    ];
    programs = lib.pipe project.nixos.modules.programs [
      (lib.mapAttrs (name: value: value.examples))
    ];
  }) projects;

  raw-tests = lib.mapAttrs (projectName: project: {
    services = lib.pipe project.services [
      (lib.mapAttrs (_: example: lib.concatMapAttrs (_: value: value.tests) example))
      (lib.filterAttrs (_: test: (!test ? problem.broken) && (test ? module && test.module != null)))
      (lib.mapAttrs (_: test: lib.mapAttrs (_: value: value.module) test))
    ];
    programs = lib.pipe project.programs [
      (lib.mapAttrs (_: example: lib.concatMapAttrs (_: value: value.tests) example))
      (lib.filterAttrs (_: test: (!test ? problem.broken) && (test ? module && test.module != null)))
      (lib.mapAttrs (_: test: lib.mapAttrs (_: value: value.module) test))
    ];
    demo = lib.mapAttrs (_: value: value.module) (raw-demos.${projectName}.tests or { });
  }) examples;

  tests = import ./tests.nix {
    inherit
      lib
      pkgs
      raw-tests
      sources
      ;
  };

  # TODO: migrate and remove this
  compat._examples = lib.mapAttrs (
    _: project:
    lib.pipe project.nixos.examples [
      (lib.concatMapAttrs (_: example: example))
      (lib.filterAttrs (_: value: value.module != null))
    ]
  ) compat.projects;

  compat._modules = {
    services = lib.concatMapAttrs (_: project: project.services) modules;
    programs = lib.concatMapAttrs (_: project: project.programs) modules;
  };
  compat._tests = tests;

  compat.projects = lib.genAttrs project-names (name: {
    metadata = metadata.${name};
    nixos.demo = raw-demos.${name} or { };
    nixos.modules = modules.${name};
    nixos.examples = lib.concatMapAttrs (_: value: value) examples.${name};
    nixos.tests = compat._tests.${name};
  });
}
