{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auth-ldap";
  version = "0-unstable-2025-10-29";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b6ee1eee69f3e7ffd951c354b39f22207f500f57";
    sparseCheckout = [ "peertube-plugin-auth-ldap" ];
    hash = "sha256-1l8GrkJU+eDlUjJd36o3F8o6OAXZR9SF5un1W2gDQcU=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auth-ldap";

  npmDepsHash = "sha256-Q3HDMv8Suac3y8yP+obnnMuhKS6gteHfmVZjfzCkUBY=";

  dontNpmBuild = true;

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Add LDAP support to login form in PeerTube";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auth-ldap";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
