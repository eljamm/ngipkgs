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

    checks = default.inputs.flake-utils.filterPackages system (default.import ./checks.nix { });
  };

  systemAgnostic = {
    lib = default.overlays.customLib null null;

    nixosConfigurations = {
      makemake = import ./infra/makemake { inherit (default) inputs; };
    };

    # WARN: this is currently unstable and subject to change in the future
    nixosModules = default.nixos-modules;

    # Overlays a package set (e.g. Nixpkgs) with the packages defined in this flake.
    overlays.default = default.overlays.default;
  };
}
