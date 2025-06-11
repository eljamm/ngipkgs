{
  lib,
  pkgs,
  sources,
  extendedNixosModules,
}:
let
  demo-module = {
    imports = [
      ./demo.nix
      ./shell.nix
    ];
    demo.enable = true;
  };

  eval =
    module: type:
    (import (sources.nixpkgs + "/nixos/lib/eval-config.nix") {
      system = "x86_64-linux";
      modules = [
        module
        demo-module
      ] ++ extendedNixosModules;
      specialArgs.sources.inputs = sources;
    }).config;

  activate = module: type: (eval module type).demo.${type}.activate;

  demo-vm =
    module:
    pkgs.writeShellScript "demo-vm" ''
      exec ${activate module "vm"}/bin/run-nixos-vm "$@"
    '';

  demo-shell = module: activate module "shell";

  xrsh = eval ../../projects/xrsh/programs/xrsh/examples/basic.nix "shell";
in
{
  inherit
    demo-vm
    demo-shell
    demo-module
    xrsh
    ;
}
