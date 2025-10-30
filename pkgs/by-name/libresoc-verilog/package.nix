{
  callPackage,
  libresoc-nmigen,
}:
let
  inherit (libresoc-nmigen.passthru) fetchFromLibresoc;

  pinmux = callPackage ./pinmux.nix { inherit fetchFromLibresoc; };
in
callPackage ./verilog.nix {
  inherit pinmux libresoc-nmigen;
}
