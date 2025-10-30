{
  lib,
  newScope,
  fetchgit,
}:
let
  deps = lib.makeScope newScope (
    self:
    let
      callPackage = self.newScope {
        # given recent poor availability of upstream https://git.libre-soc.org/,
        # define a dedicated fetcher for current mirror source
        # (currently github.com/Libre-SOC-mirrors, cc @jleightcap @albertchae)
        fetchFromLibresoc =
          {
            pname,
            hash,
            rev,
            fetchSubmodules ? true,
          }:
          fetchgit {
            url = "https://github.com/Libre-SOC-mirrors/${pname}.git";
            inherit rev hash fetchSubmodules;
          };
      };
    in
    {
      libresoc-c4m-jtag = callPackage ./libresoc-c4m-jtag.nix { };
      libresoc-ieee754fpu = callPackage ./ieee754fpu.nix { };
      libresoc-openpower-isa = callPackage ./openpower-isa.nix { };
      libresoc-pyelftools = callPackage ./libresoc-pyelftools.nix { };
      sfpy = callPackage ./sfpy.nix { };
      bigfloat = callPackage ./bigfloat.nix { };
      mdis = callPackage ./mdis.nix { };
      nmigen = callPackage ./nmigen.nix { };
      nmigen-soc = callPackage ./nmigen-soc.nix { };
      nmutil = callPackage ./nmutil.nix { };
      power-instruction-analyzer = callPackage ./power-instruction-analyzer.nix { };
      pytest-output-to-files = callPackage ./pytest-output-to-files.nix { };
      modgrammar = callPackage ./modgrammar.nix { };
      soc = callPackage ./soc.nix { };
    }
  );
in
deps.soc
