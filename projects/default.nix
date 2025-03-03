{
  lib,
  pkgs,
  sources,
  models ? import ./models.nix {
    inherit lib pkgs;
    sources = sources.inputs;
  },
}:
let
  inherit (builtins)
    elem
    readDir
    trace
    ;

  inherit (lib.attrsets)
    concatMapAttrs
    mapAttrs
    filterAttrs
    ;

  inherit (models)
    project
    ;

  migrateProject = new-project: {
    packages = new-project.nixos.modules.packages;
  };

  baseDirectory = ./.;

  projectDirectories =
    let
      names =
        name: type:
        if type == "directory" then
          { ${name} = baseDirectory + "/${name}"; }
        # nothing else should be kept in this directory reserved for projects
        else
          assert elem name allowedFiles;
          { };
      allowedFiles = [
        "README.md"
        "default.nix"
        "models.nix"
      ];
    in
    # TODO: use fileset and filter for `gitTracked` files
    concatMapAttrs names (readDir baseDirectory);
in
mapAttrs (
  name: directory: migrateProject (project (import directory { inherit lib pkgs sources; }))
) projectDirectories
