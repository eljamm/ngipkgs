{
  lib,
  newScope,
  unstableGitUpdater,
  buildNpmPackage,
}:
lib.makeScope newScope (
  self:
  let
    callPackage = self.newScope {
      buildNpmPackage =
        args:
        buildNpmPackage args
        // {
          passthru.updateScript = [
            ./update.sh
            (unstableGitUpdater { })
          ];
        };
    };
  in
  {
    akismet = callPackage ./peertube-plugin-akismet/package.nix { };
    auth-ldap = callPackage ./peertube-plugin-auth-ldap/package.nix { };
    auth-openid-connect = callPackage ./peertube-plugin-auth-openid-connect/package.nix { };
    auth-saml2 = callPackage ./peertube-plugin-auth-saml2/package.nix { };
    auto-block-videos = callPackage ./peertube-plugin-auto-block-videos/package.nix { };
    auto-mute = callPackage ./peertube-plugin-auto-mute/package.nix { };
    hello-world = callPackage ./peertube-plugin-hello-world/package.nix { };
    livechat = callPackage ./peertube-plugin-livechat/package.nix { };
    logo-framasoft = callPackage ./peertube-plugin-logo-framasoft/package.nix { };
    matomo = callPackage ./peertube-plugin-matomo/package.nix { };
    privacy-remover = callPackage ./peertube-plugin-privacy-remover/package.nix { };
    transcoding-custom-quality =
      callPackage ./peertube-plugin-transcoding-custom-quality/package.nix
        { };
    transcoding-profile-debug = callPackage ./peertube-plugin-transcoding-profile-debug/package.nix { };
    video-annotation = callPackage ./peertube-plugin-video-annotation/package.nix { };
  }
)
