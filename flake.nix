{
  description = "NGIpkgs";

  inputs.dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.dream2nix.url = "github:nix-community/dream2nix";

  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

  inputs.sbt-derivation.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sbt-derivation.url = "github:zaninime/sbt-derivation";

  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = "github:Mic92/sops-nix";

  inputs.buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.buildbot-nix.url = "github:nix-community/buildbot-nix";

  inputs.nixdoc-to-github.flake = false;
  inputs.nixdoc-to-github.url = "github:fricklerhandwerk/nixdoc-to-github";

  # See <https://github.com/ngi-nix/ngipkgs/issues/24> for plans to support Darwin.
  inputs.systems.url = "github:nix-systems/default-linux";

  # NOTE:
  # The flake attributes are constructed from ./default.nix, so please refer to
  # that file for reference.
  outputs =
    {
      self,
      flake-utils,
      ...
    }@inputs:
    let
      flake = self;
      sources = inputs;
      importFlake =
        arg: (system: (import ./. { inherit flake sources system; }).flakeAttrs.${arg} or { });
      systemAgnosticOutputs = flake-utils.lib.eachDefaultSystemPassThrough (importFlake "systemAgnostic");
      eachDefaultSystemOutputs = flake-utils.lib.eachDefaultSystem (importFlake "systemAgnostic");
    in
    eachDefaultSystemOutputs // systemAgnosticOutputs;
}
