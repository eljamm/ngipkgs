{
  lib,
  name,
  config,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    ;
in
{
  options = {
    heading = mkOption {
      type = types.str;
      default = ''
        <a class="heading" href="#examples">
          <h2 id="examples">
            Examples
            <span class="anchor"/>
          </h2>
        </a>
      '';
    };
    examples = mkOption {
      type = with types; listOf (submodule ./example.nix);
    };
    button-add-example = mkOption {
      type = types.str;
      default = ''
        <button class="button example"><a class = "heading" href="https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md#how-to-add-an-example">Add an example</a></button>
      '';
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default = self: ''
        ${self.heading}
        ${lib.concatLines (map toString self.examples)}
        ${self.button-add-example}
      '';
    };
  };
}
