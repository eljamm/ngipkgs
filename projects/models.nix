{
  lib,
  pkgs,
  sources,
}:
let
  yants = import sources.yants { };

  inherit (yants)
    string
    list
    option
    attrs
    enum
    either
    any
    ;

  optionalAttrs = option (attrs (option string));
in
rec {
  project =
    p: with p; {
      name = string name;
      metadata = with metadata; {
        summary = string summary;
        funds = list (enum [
          "Commons"
          "Core"
          "Entrust"
          "Review"
        ]) funds;
        status = string status;
        websites = (either optionalAttrs any) {
          repo = websites.repo;
          docs = websites.docs or null;
          blog = websites.blog or null;
          forum = websites.forum or null;
          matrix = websites.matrix or null;
          other = list string (websites.other or [ ]);
        };
        contact = optionalAttrs {
          email = contact.email or null;
        };
      };
    };

  example = project {
    name = "";
    metadata = {
      summary = "";
      websites = {
        repo = "";
        docs = "";
      };
      funds = [ "Review" ];
      status = "";
      contact = null;
    };
  };
}
