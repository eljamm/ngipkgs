{
  lib,
  pkgs,
  sources,
  tests,
  ...
}:
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
      debugging.interactive.nodes = lib.mapAttrs (_: _: tools) test.nodes;
      args = lib.mergeAttrsList [
        debugging
        test
        {
          # we need to extend pkgs with ngipkgs, so it can't be read-only
          node.pkgsReadOnly = false;
        }
      ];
    in
    if lib.isDerivation test then test else pkgs.testers.runNixOSTest args;

  filtered-tests = lib.filterAttrs (
    _: test: (!test ? problem.broken) && (test ? module && test.module != null)
  ) tests;
in
lib.mapAttrs (
  _: test:
  if lib.isPath test.module then
    nixosTest (
      import test.module {
        inherit pkgs lib sources;
        inherit (pkgs) system;
      }
    )
  else
    nixosTest test.module
) filtered-tests
