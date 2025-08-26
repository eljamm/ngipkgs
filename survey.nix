{ lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;

  choice = types.enum [
    "Yes"
    "Not planned"
    "Not yet"
  ];

  choice2 = types.enum [
    "Yes"
    "Not sure yet"
    "No"
  ];
in
{
  options = {
    project = mkOption {
      type = types.str;
    };
    feedback = mkOption {
      type = types.lines;
    };
    nix-help = mkOption {
      type = types.lines;
      description = "Parts of the authors' projects that Nix/NixOS can help with";
    };
    repositories = mkOption {
      type = types.lines;
    };
    artefacts = mkOption {
      type = types.submodule {
        options = {
          programs-cli = mkOption {
            type = types.nullOr choice;
            default = null;
          };
          programs-gui = mkOption {
            type = types.nullOr choice;
            default = null;
          };
          services = mkOption {
            type = types.nullOr choice;
            default = null;
          };
          libraries = mkOption {
            type = types.nullOr choice;
            default = null;
          };
          extensions = mkOption {
            type = types.nullOr choice2;
            default = null;
          };
          mobile = mkOption {
            type = types.nullOr choice;
            default = null;
          };
        };
      };
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default =
        self:
        ''
          # ${self.project}

        ''
        + lib.optionalString (self.repositories != "") ''
          ## Code Repositories

          ${self.repositories}

        ''
        + lib.optionalString (self.nix-help != "") ''
          ## Parts Nix can help with

          ${self.nix-help}

        ''
        + lib.optionalString (self.feedback != "") ''
          ## Feedback

          ${self.feedback}

        '';
    };
  };
}
