{
  lib,
  pkgs,
  system,
  default,
  ...
}:
{
  perSystem = {
    packages = default.ngipkgs // {
      inherit (default) overview demos;

      options =
        pkgs.runCommand "options.json"
          {
            build = default.optionsDoc.optionsJSON;
          }
          ''
            mkdir $out
            cp $build/share/doc/nixos/options.json $out/
          '';
    };

    checks = default.sources.flake-utils.lib.filterPackages system (default.call ./checks.nix { });
  };

  systemAgnostic = {
    lib = default.overlays.customLib null null;

    nixosConfigurations = {
      makemake = import ../../infra/makemake { inputs = default.sources; };
    };

    toplevel = machine: machine.config.system.build.toplevel; # for makemake

    # WARN: this is currently unstable and subject to change in the future
    nixosModules = default.nixos-modules;

    # Overlays a package set (e.g. Nixpkgs) with the packages defined in this flake.
    overlays.default = default.overlays.default;
  };
}
