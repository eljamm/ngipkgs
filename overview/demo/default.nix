{
  lib,
  pkgs,
  sources,
  extendedNixosModules,
}:
let
  nixosSystem =
    args:
    import (sources.nixpkgs + "/nixos/lib/eval-config.nix") (
      {
        inherit lib;
        system = null;
      }
      // args
    );

  demo-system =
    module:
    nixosSystem {
      system = "x86_64-linux";
      modules = [
        module
        {
          imports = [
            "${sources.nix-system-graphics}/system/modules/graphics.nix"
            ./system-manager.nix
          ];

          # system-manager.allowAnyDistro = true;
          system-graphics.enable = true;

          environment.systemPackages = [
            pkgs.mesa-demos
          ];
        }
        (sources.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
        (sources.nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix")
        (
          { config, ... }:
          {
            users.users.nixos = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
              initialPassword = "nixos";
            };

            users.users.root = {
              initialPassword = "root";
            };

            security.sudo.wheelNeedsPassword = false;

            services.getty.autologinUser = "nixos";
            services.getty.helpLine = ''

              Welcome to NGIpkgs!
            '';

            services.openssh = {
              enable = true;
              ports = [
                10022
              ];
              settings = {
                PasswordAuthentication = true;
                PermitEmptyPasswords = "yes";
                PermitRootLogin = "yes";
              };
            };

            system.stateVersion = "25.05";

            networking.firewall.enable = false;

            virtualisation = {
              memorySize = 4096;
              cores = 4;
              graphics = false;

              qemu.options = [
                "-cpu host"
                "-enable-kvm"
              ];

              # ssh + open service ports
              forwardPorts = map (port: {
                from = "host";
                guest.port = port;
                host.port = port;
                proto = "tcp";
              }) config.networking.firewall.allowedTCPPorts;
            };
          }
        )
        ./shell.nix
      ] ++ extendedNixosModules;
      specialArgs = { inherit sources; };
    };
in
rec {
  demo-vm =
    module:
    pkgs.writeShellScript "demo-vm" ''
      exec ${(demo-system module).config.system.build.vm}/bin/run-nixos-vm "$@"
    '';

  demo-shell = module: (demo-system module).config.shells.bash.activate;

  demo-test = demo-shell /home/kuroko/Files/System/Development/Git/Personal/nix/ngipkgs/projects/mitmproxy/example.nix;
}
