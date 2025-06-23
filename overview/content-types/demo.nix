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
    heading = mkOption {
      type = types.str;
    };
    installation-instructions = mkOption {
      type = types.submodule ./shell-instructions.nix;
    };
    set-nix-config = mkOption {
      type = types.submodule ./shell-instructions.nix;
    };
    build-instructions = mkOption {
      type = types.submodule ./shell-instructions.nix;
    };
    demo-snippet = mkOption {
      type = types.submodule ./demo-snippet.nix;
    };
    __toString = mkOption {
      type = with types; functionTo str;
      # TODO: refactor?
      default = self: ''
        ${self.heading}

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
