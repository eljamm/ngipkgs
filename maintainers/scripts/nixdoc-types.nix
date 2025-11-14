{
  callPackage,
  sources,
  ...
}:
let
  nixdoc-to-github = callPackage sources.nixdoc-to-github { };
in
# nix-shell --run nixdoc-to-github
nixdoc-to-github.lib.nixdoc-to-github.run {
  description = "NGI Project Types";
  category = "";
  file = "${toString ../../projects/types.nix}";
  output = "${toString ../docs/project.md}";
}
