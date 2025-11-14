let
  flake-inputs = import (fetchTarball {
    url = "https://github.com/fricklerhandwerk/flake-inputs/tarball/4.1.0";
    sha256 = "1j57avx2mqjnhrsgq3xl7ih8v7bdhz1kj3min6364f486ys048bm";
  });
  inherit (flake-inputs)
    import-flake
    ;
in
{
  flake ? import-flake { src = ./.; },
  sources ? flake.inputs,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs {
    config = { };
    overlays = import ./pkgs/overlays.nix { inherit lib; };
    inherit system;
  },
  lib ? import "${sources.nixpkgs}/lib",
}:
let
  extension = import ./pkgs/lib.nix { inherit lib sources system; };

  scope = lib.makeScope pkgs.newScope (self: {
    lib = lib.extend (_: _: extension);

    inherit
      pkgs
      system
      sources
      extension
      ;

    # import file while passing all scope attributes as input
    call = self.callPackage;

    ngipkgs = self.call ./pkgs/by-name { };

    overlays.default =
      final: prev:
      import ./pkgs/by-name {
        pkgs = prev;
        inherit (self) lib dream2nix mkSbtDerivation;
      };

    examples = lib.mapAttrs (
      _: project: lib.mapAttrs (_: example: example.module) self.project.nixos.examples
    ) self.hydrated-projects;

    nixos-modules =
      with lib;
      # TODO: this is a weird shape for what we need: ngipkgs, services, modules?
      {
        # Allow using packages from `ngipkgs` to be used alongside regular `pkgs`
        ngipkgs =
          { ... }:
          {
            nixpkgs.overlays = [ self.overlays.default ];
          };
      }
      // foldl recursiveUpdate { } (
        map (project: project.nixos.modules) (attrValues self.hydrated-projects)
      );

    extendedNixosModules =
      let
        ngipkgsModules = lib.attrValues (lib.flattenAttrs "." self.nixos-modules);
        nixosModules = import "${sources.nixpkgs}/nixos/modules/module-list.nix";
      in
      nixosModules ++ ngipkgsModules;

    overview = self.call ./overview {
      self = flake;
      pkgs = pkgs.extend self.overlays.default;
      options = self.optionsDoc.optionsNix;
    };

    optionsDoc = pkgs.nixosOptionsDoc {
      inherit
        (lib.evalModules {
          modules = [
            {
              nixpkgs.hostPlatform = system;

              networking = {
                domain = "invalid";
                hostName = "options";
              };

              system.stateVersion = "23.05";
            }
            ./overview/demo/shell.nix
          ]
          ++ self.extendedNixosModules;
          specialArgs.modulesPath = "${sources.nixpkgs}/nixos/modules";
        })
        options
        ;
    };

    inherit
      (self.call ./projects {
        pkgs = pkgs.extend self.overlays.default;
        sources = {
          inputs = sources;
          modules = self.nixos-modules;
          examples = self.examples;
        };
      })
      checks
      projects
      hydrated-projects
      ;

    scripts = self.call ./maintainers/scripts { };
    shell = pkgs.mkShellNoCC {
      packages = [
        # live overview watcher:
        # nix-shell --run devmode
        (pkgs.devmode.override {
          buildArgs = "-A overview --show-trace -v";
        })

        self.scripts.ngipkgs-test

        # nix-shell --run 'update PACKAGE_NAME --use-update-script'
        self.scripts.update

        # nix-shell --run update-all
        self.scripts.update-all

        # nix-shell --run nixdoc-to-github
        self.scripts.nixdoc-types
      ];
    };

    metrics = self.call ./maintainers/metrics.nix {
      raw-projects = self.hydrated-projects;
    };

    report = self.call ./maintainers/report { };

    project-demos = lib.filterAttrs (name: value: value != null) (
      lib.mapAttrs (name: value: value.nixos.demo.vm or value.nixos.demo.shell or null) self.projects
    );

    demo = self.call ./overview/demo {
      demo-modules = lib.flatten (
        lib.mapAttrsToList (name: value: value.module-demo.imports) self.project-demos
      );
      nixos-modules = self.extendedNixosModules;
    };

    inherit (self.demo)
      demo-vm
      demo-shell
      ;

    # TODO:
    # - remove dependency on dream2nix
    # - include `mkSbtDerivation` in `lib`?
    dream2nix = (import sources.dream2nix).overrideInputs { inherit (sources) nixpkgs; };
    mkSbtDerivation =
      x:
      import sources.sbt-derivation (
        x
        // {
          inherit pkgs;
          overrides = {
            sbt = pkgs.sbt.override {
              jre = pkgs.jdk17_headless;
            };
          };
        }
      );
  });
in
scope // scope.ngipkgs
