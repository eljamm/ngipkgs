{
  lib,
  ...
}@args:

lib.attrsets.concatMapAttrs (
  name: type:
  if type == "directory" then
    {
      "${name}" = (./. + "/${name}");
    }
  else
    { }
) (builtins.readDir ./.)
