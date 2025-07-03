{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    optionalString
    any
    attrValues
    ;

  types' = import ../../projects/types.nix { inherit lib; };
in
{
  options = {
    example = mkOption {
      type = types'.example;
    };
    example-snippet = mkOption {
      type = types.submodule ./code-snippet.nix;
      default.filepath = config.example.module;
    };
    button-missing-test = mkOption {
      type = types.str;
      default = optionalString (any (test: test.module == null) (attrValues config.example.tests)) ''
        <button class="button example">
        <a class = "heading" href="https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md">Add example test</a>
        </button>
      '';
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default = self: ''
        <details><summary>${self.example.description}</summary>
        ${self.example-snippet}
        ${self.button-missing-test}
        </details>
      '';
    };
  };
}
