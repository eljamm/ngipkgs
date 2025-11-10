{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-plugin-transcoding-custom-quality";
  version = "0-unstable-2025-10-29";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b6ee1eee69f3e7ffd951c354b39f22207f500f57";
    sparseCheckout = [ "peertube-plugin-transcoding-custom-quality" ];
    hash = "sha256-m+oFaX9/8MyDAUt4omsdliAR5ZHFJzfeGkuxufWZTjM=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-transcoding-custom-quality";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Set a custom quality for transcoding";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-transcoding-custom-quality";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
