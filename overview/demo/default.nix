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
    (lib.evalModules {
      modules = [ module ] ++ demo-modules ++ extendedNixosModules;
      specialArgs.modulesPath = "${sources.nixpkgs}/nixos/modules";
      specialArgs.pkgs = pkgs;
    }).config;

  activate = module: type: (eval module type).demo.${type}.activate;

  demo-vm =
    module:
    pkgs.writeShellScript "demo-vm" ''
      exec ${activate module "vm"}/bin/run-nixos-vm "$@"
    '';

  demo-shell = module: activate module "shell";

  xrsh = demo-vm ../../projects/Cryptpad/demo.nix;
  xrsh-eval = eval ../../projects/xrsh/programs/xrsh/examples/basic.nix "shell";
in
{
  inherit
    demo-vm
    demo-shell
    demo-modules
    xrsh
    xrsh-eval
    ;
}
