{
  lib,
  pkgs,
  sources,
}@args:
{
  name = "Gnucap";
  metadata.subgrants = [
    "Gnucap-MixedSignals"
    "Gnucap-VerilogAMS"
  ];
  references = {
    wiki = {
      text = "Gnucap Wiki";
      link = "http://gnucap.org/dokuwiki/doku.php?id=gnucap:start";
    };
    manual = {
      text = "User Manual (PDF)";
      link = "https://www.gnu.org/software/gnucap/gnucap-man.pdf";
    };
    notes = {
      text = "Notes for Developers";
      link = "http://gnucap.org/dokuwiki/doku.php/gnucap:manual:tech";
    };
  };
  nixos = {
    modules.programs.gnucap = {
      module =
        { pkgs, ... }:
        {
          packages = with pkgs; [
            gnucap
            gnucap-full
          ];
        };
      # http://gnucap.org/dokuwiki/doku.php/gnucap:user:build_system_for_plugins
      # http://gnucap.org/dokuwiki/doku.php/gnucap:user:command_plugins
      plugins = null;
      examples.base = {
        module = ./module.nix;
        description = "Basic configuration, mainly used for testing purposes.";
        tests.base = null;
        references = {
          tutorial = {
            text = "Examples, tutorial";
            link = "http://gnucap.org/dokuwiki/doku.php/gnucap:manual:examples";
          };
          manual = {
            text = "Gnucap manual";
            link = "http://gnucap.org/dokuwiki/doku.php/gnucap:manual";
          };
        };
      };
      references = {
        build = {
          text = "Installation Instructions";
          link = "https://git.savannah.gnu.org/cgit/gnucap.git/tree/INSTALL";
        };
        tests = {
          text = "Running Tests";
          link = "https://git.savannah.gnu.org/cgit/gnucap.git/tree/tests/README";
        };
      };
    };
  };
}
