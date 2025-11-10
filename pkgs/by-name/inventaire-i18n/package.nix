{
  lib,
  buildNpmPackage,
  fetchFromGitea,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "inventaire-i18n";
  version = "0-unstable-2025-11-07";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "inventaire";
    repo = "inventaire-i18n";
    rev = "b1ea752a925ebef1dab7fc358fbb8f3d031b0dca";
    hash = "sha256-VYhQrsGpsGSoApS38jj/fDU6q3rv5FW6rH0X/1778Bk=";
  };

  npmDepsHash = "sha256-hJ9L9X53n44Iz0lKX2NspMLtQbQA0nRgJvYZc5+xNuA=";

  postPatch = ''
    patchShebangs scripts
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Repository hosting inventaire i18n strings and scripts";
    homepage = "https://codeberg.org/inventaire/inventaire-i18n";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
  };
})
