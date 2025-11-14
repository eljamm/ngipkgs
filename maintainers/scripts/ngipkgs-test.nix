{
  writeShellApplication,
  ...
}:
writeShellApplication {
  # TODO: have the program list available tests
  name = "ngipkgs-test";
  text = ''
    export pr="$1"
    export proj="$2"
    export test="$3"
    # remove the first args and feed the rest (for example flags)
    export args="''${*:4}"

    nix build --override-input nixpkgs "github:NixOS/nixpkgs?ref=pull/$pr/merge" .#checks.x86_64-linux.projects/"$proj"/nixos/tests/"$test" "$args"
  '';
}
