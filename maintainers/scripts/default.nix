{
  lib,
  callPackage,
  ...
}:
let
  fs = lib.fileset;
in
lib.pipe ./. [
  (fs.fileFilter (file: file.name != "default.nix"))
  (fs.toList)
  (map (
    file:
    let
      relative-path = lib.path.removePrefix ./. file;
      attrs-path = lib.pipe relative-path [
        (lib.removePrefix "./")
        (lib.removeSuffix ".nix")
        (lib.splitString "/")
      ];
    in
    lib.setAttrByPath attrs-path (callPackage file { })
  ))
  (lib.foldl lib.recursiveUpdate { })
]
