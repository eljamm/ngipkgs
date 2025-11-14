{
  nix-update,
  writeShellApplication,
  ...
}:
# NOTE: currently, this only works with flakes, because `nix-update` can't
# find `maintainers/scripts/update.nix` otherwise
#
# nix-shell --run 'update PACKAGE_NAME --use-update-script'
writeShellApplication {
  name = "update";
  runtimeInputs = [ nix-update ];
  text = ''
    package=$1; shift # past value
    nix-update --flake --use-update-script "$package" "$@"
  '';
}
