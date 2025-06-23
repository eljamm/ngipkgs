{
  lib,
  name,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options = {
    installation-instructions = mkOption {
      type = types.str;
    };
    set-nix-config = mkOption {
      type = types.str;
    };
    build-instructions = mkOption {
      type = types.str;
    };
    demo-snippet = mkOption {
      type = types.str;
    };
    __toString = mkOption {
      type = with types; functionTo str;
      # TODO: refactor?
      default = self: ''
        <ol>
          <li>
            <strong>Install Nix</strong>
            ${self.installation-instructions}
          </li>
          <li>
            <strong>Download a configuration file</strong>
            ${self.demo-snippet}
          </li>
          <li>
            <strong>Enable binary substituters</strong>
            ${self.set-nix-config}
          </li>
          <li>
            <strong>Build and run a virtual machine</strong>
            ${self.build-instructions}
          </li>
        </ol>
      '';
    };
  };
}
