{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    summary = "Omnom is a web-based, self-hosted bookmarking and snapshotting platform";
    subgrants = [
      "Omnom"
      "Omnom-ActivityPub"
    ];
  };

  # TODO: browser addons are packaged, but we need a way to represent them
  nixos.modules.services.omnom = {
    module = "${sources.inputs.nixpkgs}/nixos/modules/services/misc/omnom.nix";
    examples.base = {
      module = ./example.nix;
      description = "";
      tests.basic = null;
    };
    links = {
      # https://github.com/asciimoo/omnom/blob/master/config/config.go
      config = {
        text = "Server Config";
        url = "https://github.com/asciimoo/omnom/blob/master/config.yml_sample";
      };
    };
  };
}
