{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;

  types' = import ../../projects/types.nix { inherit lib; };
in
{
  options = {
    example-snippet = mkOption {
      type = types.submodule ./code-snippet.nix;
      default.filepath = example.module;
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default = self: ''
        <details><summary>${example.description}</summary>
        ${self.example-snippet}
        ${optionalString (lib.any (test: test.module == null) (lib.attrValues example.tests)) ''
          <button class="button example"><a class = "heading" href="https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md">Add example test</a></button>
        ''}
        ${render.codeSnippet.one { filename = example.module; }}

        </details>
      '';
    };
  };
}
