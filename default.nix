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
    overlays = import ./pkgs/overlays.nix { lib = nixpkgsLib; };
    inherit system;
  },
  nixpkgsLib ? import "${sources.nixpkgs}/lib",
}:
let
  flakeAttrs = {
    perSystem = {
      packages = default.ngipkgs;
    };

    systemAgnostic = {
      inherit (default) overlays;
    };
  };

  lib = default.lib;

  default = nixpkgsLib.makeScope pkgs.newScope (self: {
    lib = nixpkgsLib.extend self.overlays.customLib;

    # Similar to `pkgs.callPackage`, but aware of `default` scope attributes.
    # The result is overridable.
    call = self.newScope {
      nixdoc-to-github = pkgs.callPackage sources.nixdoc-to-github { };
      dream2nix = (import sources.dream2nix).overrideInputs { inherit (sources) nixpkgs; };
    };

    # Similar to `import`, but aware of `default` scope attributes.
    # Non overridable.
    import =
      f: args:
      removeAttrs (self.call f args) [
        "override"
        "overrideDerivation"
      ];

    inherit
      pkgs
      system
      sources
      ;

    ngipkgs = self.import ./pkgs/by-name { };

    shell = self.import ./maintainers/shells/default.nix { };

    overlays = {
      default =
        final: prev:
        self.import ./pkgs/by-name {
          pkgs = prev;
        };

      customLib =
        _: _:
        self.import ./pkgs/lib.nix {
          lib = nixpkgsLib;
        };

      fixups = self.import ./pkgs/overlays.nix { };
    };

    overview = self.import ./overview {
      inherit projects;
      self = flake;
      pkgs = pkgs.extend self.overlays.default;
      options = self.optionsDoc.optionsNix;
    };

    ##
    examples =
      with lib;
      mapAttrs (
        _: project: mapAttrs (_: example: example.module) project.nixos.examples
      ) hydrated-projects;

    nixos-modules =
      with lib;
      # TODO: this is a weird shape for what we need: ngipkgs, services, modules?
      {
        # Allow using packages from `ngipkgs` to be used alongside regular `pkgs`
        ngipkgs =
          { ... }:
          {
            nixpkgs.overlays = [ self.overlays.default ] ++ self.overlays.fixups;
          };
      }
      // foldl recursiveUpdate { } (map (project: project.nixos.modules) (attrValues hydrated-projects));

    extendedNixosModules =
      let
        ngipkgsModules = lib.attrValues (lib.flattenAttrs "." self.nixos-modules);
        nixosModules = import "${sources.nixpkgs}/nixos/modules/module-list.nix";
      in
      nixosModules ++ ngipkgsModules;

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

    metrics = self.import ./maintainers/metrics.nix {
      raw-projects = hydrated-projects;
    };

    report = self.import ./maintainers/report { };
  });

  inherit
    (import ./projects {
      inherit lib system;
      pkgs = pkgs.extend default.overlays.default;
      sources = {
        inputs = sources;
        modules = default.nixos-modules;
        inherit (default) examples;
      };
    })
    checks
    projects
    hydrated-projects
    ;

  inherit
    (import ./overview/demo {
      inherit
        lib
        pkgs
        sources
        system
        projects
        ;
      nixos-modules = default.extendedNixosModules;
    })
    # for demo code activation. used in the overview code snippets
    demo-shell
    demo-vm
    # - $(nix-build -A demos.PROJECT_NAME)
    # - nix run .#demos.PROJECT_NAME
    demos
    ;
in
default
# required for update scripts
// default.ngipkgs
