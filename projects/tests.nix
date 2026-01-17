{
  lib,
  pkgs,
  raw-tests,
  sources,
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
            fonts = [
              {
                name = "Hack";
                package = pkgs.hack-font;
              }
            ];
          };
        };
      debugging.interactive.nodes = lib.mapAttrs (_: _: tools) test.nodes;
      args = {
        imports = [
          debugging
          test
        ];
        # we need to extend pkgs with ngipkgs, so it can't be read-only
        node.pkgsReadOnly = false;
      };
    in
    if lib.isDerivation test then test else pkgs.testers.runNixOSTest args;

  callTest =
    test:
    if lib.isString test || lib.isPath test then
      nixosTest (
        import test {
          inherit pkgs lib sources;
          inherit (pkgs) system;
        }
      )
    else
      nixosTest test;
in
# turn all leaf nodes into NixOS test derivations
lib.mapAttrsRecursiveCond (as: !(as ? "type" && as.type == "derivation")) (path: callTest) raw-tests
