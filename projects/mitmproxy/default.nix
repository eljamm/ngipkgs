{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Interactive TLS-capable intercepting HTTP proxy";
    subgrants.Entrust = [
      "mitmproxy"
    ];
  };

  nixos.modules.programs = {
    mitmproxy = {
      module = ./module.nix;
      examples.basic = {
        module = ./demo.nix;
        description = "";
        tests.basic.module = ./services/mitmproxy/tests/basic.nix;
      };
    };
  };
  nixos.demo.shell = {
    module = ./demo.nix;
    module-demo = ./module-demo.nix;
    description = "";
    tests.demo.module = pkgs.nixosTests.mitmproxy;
  };
}
