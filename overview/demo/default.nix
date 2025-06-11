{
  lib,
  pkgs,
  sources,
  extendedNixosModules,
}:
let
  eval =
    modules:
    (import (sources.nixpkgs + "/nixos/lib/eval-config.nix") {
      system = "x86_64-linux";
      modules = modules ++ extendedNixosModules;
      specialArgs.sources.inputs = sources;
    }).config;

  demo =
    module: type:
    let
      demo-system = eval [
        module
        {
          imports = [ ./demo.nix ];
          demo = {
          };
        }
      ];
    in
    if type == "vm" then demo-system.system.build.vm else demo-system.shells.bash.activate;

  demo-vm =
    module:
    pkgs.writeShellScript "demo-vm" ''
      exec ${demo module "vm"}/bin/run-nixos-vm "$@"
    '';

  demo-shell = module: demo module "shell";
in
{
  inherit
    demo-vm
    demo-shell
    demo-modules
    ;
}
