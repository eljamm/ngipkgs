{
  lib,
  pkgs,
  sources,
  system,
  ...
}@args:
let
  inherit (builtins)
    elem
    elemAt
    readDir
    trace
    ;

  inherit (lib.attrsets)
    concatMapAttrs
    mapAttrs
    ;

  inherit (lib.fileset)
    fileFilter
    toList
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
        "types.nix"
      ];
    in
    # TODO: use fileset and filter for `gitTracked` files
    concatMapAttrs names (readDir baseDirectory);

  projectDirectories2 = lib.pipe ./. [
    (lib.fileset.fileFilter (file: file.name == "default.nix"))
    (lib.fileset.toList)
    (map (
      file:
      let
        # return the relative path of the file as a string, compared to the
        # current directory
        relative-path = lib.path.removePrefix ./. file;

        project-name = lib.pipe relative-path [
          # clean up and return project name
          (lib.removePrefix "./")
          (lib.removeSuffix "default.nix")
          (lib.splitString "/")
          (list: lib.elemAt list 0)
        ];
      in
      project-name
    ))

    # remove files in ./.
    (lib.filter (name: name != ""))

    # get modules
    (map (filename: "${./.}/${filename}/default.nix"))
  ];
in
rec {
  inherit projectDirectories2;

  raw-projects = {
    options.projects = types.options.projects;
    config.projects = mapAttrs (name: directory: import directory args) projectDirectories2;
  };

  eval-projects = lib.evalModules {
    modules = [
      { options = types.options; }
    ]
    ++ projectDirectories2;
    specialArgs = {
      inherit pkgs system;
      modulesPath = "${sources.nixpkgs}/nixos/modules";
    };
  };

  projects = eval-projects.config.projects;

  # Force recursive evaluation for all projects
  checks = lib.mapAttrs (
    name: value: pkgs.writeText "${name}-eval-check" (lib.strings.toJSON value)
  ) (lib.forceEvalRecursive projects);

  # TODO: no longer useful. refactor whatever needs this and remove.
  hydrated-projects =
    with lib;
    let
      empty-if-null = x: if x != null then x else { };

      hydrate =
        # we use fields to track state of completion.
        # - `null` means "expected but missing"
        # - not set means "not applicable"
        # TODO: encode this in types, either yants or the module system
        project: rec {
          metadata = empty-if-null (filterAttrs (_: m: m != null) (project.metadata or { }));
          nixos.demo = filterAttrs (_: m: m != null) (empty-if-null (project.nixos.demo or { }));
          nixos.modules.services = filterAttrs (_: m: m != null) (
            lib.mapAttrs (name: value: value.module or null) project.nixos.modules.services or { }
          );
          nixos.modules.programs = filterAttrs (_: m: m != null) (
            lib.mapAttrs (name: value: value.module or null) project.nixos.modules.programs or { }
          );
          # TODO: access examples for services and programs separately?
          nixos.examples = lib.filterAttrs (name: example: example.module != null) (
            (empty-if-null (project.nixos.examples or { }))
            // (filter-map (project.nixos.modules.programs or { }) "examples")
            // (filter-map (project.nixos.modules.services or { }) "examples")
          );
          nixos.tests = import ./tests.nix {
            inherit lib pkgs project;
            inherit (nixos) examples;
          };
        };
    in
    mapAttrs (name: hydrate) raw-projects.config.projects;
}
