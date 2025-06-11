{
  sources,
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    ;

  makeManPath = lib.makeSearchPathOutput "man" "share/man";

  activate =
    demo-shell:
    pkgs.writeShellApplication rec {
      name = "demo-shell";
      runtimeInputs = lib.attrValues (lib.concatMapAttrs (name: value: value.programs) demo-shell);
      runtimeEnv = lib.concatMapAttrs (name: value: value.env) demo-shell;
      passthru.inheritManPath = false;
      # HACK: start shell from ./result
      derivationArgs.postCheck = ''
        mv $out/bin/$name /tmp/$name
        rm -rf $out && mv /tmp/$name $out
      '';
      text =
        lib.optionalString (runtimeInputs != [ ]) ''
          export MANPATH="${makeManPath runtimeInputs}${lib.optionalString passthru.inheritManPath ":$MANPATH"}"
        ''
        + ''
          export PS1="\[\033[1m\][demo-shell]\[\033[m\]\040\w >\040"

          ${pkgs.lib.getExe pkgs.bash} --norc "$@"
        '';
    };
in
{
  options.demo.shells = mkOption {
    type =
      with types;
      submodule {
        options = {
          bash.enable = mkOption {
            type = bool;
            default = true;
          };
          bash.activate = mkOption {
            type = nullOr package;
            default = null;
          };
        };
        config = lib.mkIf config.demo.shells.bash.enable {
          bash.activate = activate config.demo.shell.projects;
        };
      };
    default = { };
  };
}
