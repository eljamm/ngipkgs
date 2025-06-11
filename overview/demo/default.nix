{
  lib,
  pkgs,
  sources,
  extendedNixosModules,
}:
let
  demo-modules = [
    ./demo.nix
    ./shell.nix
    ./vm.nix
  ];

  eval =
    module: type:
    (import (sources.nixpkgs + "/nixos/lib/eval-config.nix") {
      system = "x86_64-linux";
      modules =
        [
          module
          { demo.enable = true; }
        ]
        ++ demo-modules
        ++ extendedNixosModules;
      specialArgs.modulesPath = "${sources.nixpkgs}/nixos/modules";
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
    demo-modules
    xrsh
    ;
}
