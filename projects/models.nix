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
    ;
in
rec {
  project =
    p: with p; {
      name = string name;
      metadata = with metadata; {
        summary = string summary;
        fund = string fund;
        status = string status;

        websites = with websites; {
          repo = string repo;
          docs = option string (websites.docs or null);
          other = list string other;

          contact = option (attrs (option string)) {
            email = contact.email or null;
            forum = contact.forum or null;
            matrix = contact.matrix or null;
            blog = contact.blog or null;
          };
        };
      };
    };

  example = project {
    name = "";
    metadata = {
      summary = "";
      websites = {
        repo = "";
        contact = null;
        other = [ ];
      };
      fund = "";
      status = "";
    };
  };
}
