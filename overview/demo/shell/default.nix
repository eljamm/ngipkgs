{
  lib,
  pkgs,
  apps ? null,
  command ? null,
}:

let
  inherit (lib)
    getAttrFromPath
    makeBinPath
    splitString
    isString
    isList
    ;

  stringToPackage = str: getAttrFromPath (splitString "." str) pkgs;

  getAppList =
    value:
    if isString value then
      map stringToPackage (splitString "," value)
    else if isList value then
      value
    else
      [ ];

  appsList = getAppList apps;
  appsPath = if apps != null then "export PATH=${makeBinPath appsList}:$PATH" else "";

  runCommand = if command != null then "-c '${command}'" else "";

  activate = pkgs.writeShellScript "demo-shell" ''
    export PS1="\[\033[1m\][app-shell]\[\033[m\]\040\w >\040"
    ${appsPath}

    ${pkgs.lib.getExe pkgs.bash} --norc ${runCommand}
  '';
in
activate
