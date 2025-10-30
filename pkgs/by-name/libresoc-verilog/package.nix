{
  callPackage,
  libresoc-nmigen,
}:
let
  inherit (libresoc-nmigen.passthru) fetchFromLibresoc;

  pinmux = callPackage ./pinmux.nix { inherit fetchFromLibresoc; };
  verilog = callPackage ./verilog.nix { inherit pinmux libresoc-nmigen; };
in
verilog
