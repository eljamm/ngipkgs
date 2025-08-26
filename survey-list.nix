{ lib, ... }:
let
  inherit (lib)
    mkOption
    types
    concatLines
    ;
in
{
  options = {
    projects = mkOption {
      type = with types; listOf (submodule ./survey.nix);
      default = [ ];
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default = self: concatLines (map toString self.projects);
    };
  };
}
