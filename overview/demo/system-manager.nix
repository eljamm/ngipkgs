{ lib, ... }:
{
  options = {
    system-manager.preActivationAssertions.systemGraphicsEnsureNoNixOS = lib.mkOption {
      type =
        with lib.types;
        attrsOf (
          submodule (
            { name, ... }:
            {
              options = {
                enable = lib.mkEnableOption "the assertion";

                name = lib.mkOption {
                  type = types.str;
                  default = name;
                };

                script = lib.mkOption {
                  type = types.str;
                };
              };
            }
          )
        );
      default = { };
    };
  };
}
