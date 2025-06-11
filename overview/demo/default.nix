{
  lib,
  pkgs,
  sources,
  extendedNixosModules,
}:
let
  demo-system =
    demo-module:
    import (sources.nixpkgs + "/nixos/lib/eval-config.nix") {
      system = "x86_64-linux";
      modules = [
        demo-module
        ./shell.nix
        ./vm
      ] ++ extendedNixosModules;
      specialArgs = { inherit sources; };
    };
in
{
  demo-vm =
    module:
    pkgs.writeShellScript "demo-vm" ''
      exec ${(demo-system module).config.system.build.vm}/bin/run-nixos-vm "$@"
    '';

  demo-shell = module: (demo-system module).config.shells.bash.activate;
}
