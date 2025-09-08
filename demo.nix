{
  ngipkgs ? import ./. { },
}:
ngipkgs.demo-shell (
  { ... }:

  {
    programs.ThresholdOPRF.enable = true;
  }
)
