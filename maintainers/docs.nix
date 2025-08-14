# Adapted from https://github.com/fricklerhandwerk/nixdoc-to-github
{
  writeShellApplication,
  nixdoc,
  stdenv,
  coreutils,
  gnused,
  gawk,
  busybox,
  perl,
}:
{
  run =
    {
      description,
      category,
      file,
      output,
    }:
    writeShellApplication {
      name = "nixdoc-to-github";
      runtimeInputs =
        let
          posix =
            if stdenv.isDarwin then
              [
                coreutils
                gnused
                gawk
              ]
            else
              [ busybox ];
        in
        [
          nixdoc
          perl
        ]
        ++ posix;
      # nixdoc makes a few assumptions that are specific to the Nixpkgs manual.
      # Those need to be adapated to GitHub Markdown:
      # - Turn `:::{.example}` blocks into block quotes
      # - Remove section anchors
      # - Unescape nested block comments
      # - GitHub produces its own anchors, change URL fragments accordingly
      text = ''
        nixdoc --category "${category}" --description "${description}" --file "${file}" | awk '
        BEGIN { p=0; colons=0; }
        /^\:+\{\.(caution|important|note|tip|warning|example)\}/ {
            match($0, /^:+\{/)
            colons = RLENGTH - 1
            match($0, /\.(caution|important|note|tip|warning|example)\}/)

            # Extract the alert type
            alert_type = substr($0, RSTART + 1, RLENGTH - 2)

            # Capitalize the first letter and combine with the rest of the word
            first_char = toupper(substr(alert_type, 1, 1))
            rest_of_word = substr(alert_type, 2)
            formatted_alert = first_char rest_of_word

            print "> **" formatted_alert "**"
            p = 1
            next
        }
        p && match($0, /^:+/) && RLENGTH == colons {
            p = 0
            next
        }
        p { print "> " $0; next; }
        { print }
        ' | sed 's/[[:space:]]*$//' \
          | sed 's/ {#[^}]*}//g' \
          | sed "s/\`\`\` /\`\`\`/g" \
          | sed 's#\*\\\/#\*\/#g' \
          | sed 's/function-library-//g' | perl -pe 's/\(#([^)]+)\)/"(#" . $1 =~ s|\.||gr . ")" /eg' \
          > "${output}"
      '';
    };
}
