{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auto-mute";
  version = "0-unstable-2025-10-29";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b6ee1eee69f3e7ffd951c354b39f22207f500f57";
    sparseCheckout = [ "peertube-plugin-auto-mute" ];
    hash = "sha256-K5iOYbl0VliFsIIvrmT4Ws3qic2JMjxnGmO1LnJMjN8=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auto-mute";

  npmDepsHash = "sha256-YbFEefvSLk9jf6g6FMmCahxqA+X+FD4MCc+c6luRZq4=";

  dontNpmBuild = true;

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Auto mute accounts or instances based on public blocklists";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auto-mute";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
