{
  lib,
  rustPlatform,
  fetchFromGitHub,
  perl,
  pkg-config,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tau-tower";
  version = "0.2.2-beta-unstable-2026-03-17";

  src = fetchFromGitHub {
    owner = "tau-org";
    repo = "tau-tower";
    rev = "8ba447b16a066dd92c2378514ab4949166212174";
    hash = "sha256-jSb6I5/YNVqyN7/QKZJ/5T4b+6E9/zInOpMH92j04JI=";
  };

  cargoHash = "sha256-e1q99sClAVX3y8wv2ZO1gDYyVTtNQW0jxBdtFInTDn4=";

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Webradio server - broadcasts audio source to clients";
    homepage = "https://github.com/tau-org/tau-tower";
    license = lib.licenses.eupl12;
    mainProgram = "tau-tower";
  };
})
