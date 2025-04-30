{
  lib,
  pkgs,
  raw-projects-modules,
  ...
}:
with lib;
let
  nixosTest =
    test:
    let
      # Amenities for interactive tests
      tools =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            vim
            tmux
            jq
          ];
          # Use kmscon <https://www.freedesktop.org/wiki/Software/kmscon/>
          # to provide a slightly nicer console.
          # kmscon allows zooming with [Ctrl] + [+] and [Ctrl] + [-]
          services.kmscon = {
            enable = true;
            autologinUser = "root";
          };
        };
      debugging.interactive.nodes = mapAttrs (_: _: tools) test.nodes;
    in
    pkgs.nixosTest (debugging // test);

  empty-if-null = x: if x != null then x else { };
  filter-map =
    attrs: input:
    lib.pipe attrs [
      (lib.concatMapAttrs (_: value: value."${input}" or { }))
      (lib.filterAttrs (_: v: v != null))
    ];

  hydrate =
    # we use fields to track state of completion.
    # - `null` means "expected but missing"
    # - not set means "not applicable"
    # TODO: encode this in types, either yants or the module system
    project: rec {
      metadata = empty-if-null (filterAttrs (_: m: m != null) (project.metadata or { }));
      nixos.modules.services = filterAttrs (_: m: m != null) (
        lib.mapAttrs (name: value: value.module or null) project.nixos.modules.services or { }
      );
      nixos.modules.programs = filterAttrs (_: m: m != null) (
        lib.mapAttrs (name: value: value.module or null) project.nixos.modules.programs or { }
      );
      # TODO: access examples for services and programs separately?
      nixos.examples =
        (empty-if-null (project.nixos.examples or { }))
        // (filter-map (project.nixos.modules.programs or { }) "examples")
        // (filter-map (project.nixos.modules.services or { }) "examples");
      nixos.tests = mapAttrs (
        _: test:
        if lib.isString test then
          (import test {
            inherit pkgs;
            inherit (pkgs) system;
          })
        else if lib.isDerivation test then
          test
        else
          nixosTest test
      ) ((empty-if-null project.nixos.tests or { }) // (filter-map (nixos.examples or { }) "tests"));
    };
in
mapAttrs (name: project: hydrate project) raw-projects-modules.config.projects
