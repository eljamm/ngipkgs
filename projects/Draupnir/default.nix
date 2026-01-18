{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Moderation bot for Matrix servers";
    subgrants.Core = [
      "Draupnir"
    ];
    links = {
      install = {
        text = "Build Draupnir from source";
        url = "https://the-draupnir-project.github.io/draupnir-documentation/bot/setup";
      };
      source = {
        text = "GitHub repository";
        url = "https://github.com/the-draupnir-project/Draupnir";
      };
    };
  };

  nixos = {
    modules.services.draupnir = {
      module = lib.moduleLocFromOptionString "services.draupnir";
      examples."Enable Draupnir" = {
        module = ./example.nix;
        tests.basic.module = ./services/Draupnir/tests/basic.nix;
      };
    };
    demo.vm = {
      module = ./example.nix;
      description = "Deployment for demo purposes";
      tests.basic.module = ./services/Draupnir/tests/basic.nix;
      problem.broken.reason = ''
        Still a work in progress.
      '';
    };
  };
}
