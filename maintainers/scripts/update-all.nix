{
  lib,
  nix-update,
  writeShellApplication,
  ngipkgs,
  ...
}:
let
  skipped-packages = [
    "atomic-browser" # -> atomic-server
    "atomic-cli" # -> atomic-server
    "firefox-meta-press" # -> meta-press
    "inventaire" # -> inventaire-client
    "kbin" # -> kbin-backend
    "kbin-frontend" # -> kbin-backend
    "pretalxFull" # -> pretalx
    # FIX: needs custom update script
    "marginalia-search"
    "peertube-plugin-livechat"
    # FIX: dream2nix
    "corestore"
    "liberaforms"
    # FIX: package scope
    "bigbluebutton"
    "heads"
    # FIX: don't update `sparql-queries` if there is no version change
    "inventaire-client"
    # fetcher not supported
    "libervia-backend"
    "libervia-desktop-kivy"
    "libervia-media"
    "libervia-templates"
    "sat-tmp"
    "urwid-satext"
    # broken package
    "libresoc-nmigen"
    "libresoc-verilog"
  ];
  update-packages = with lib; filter (x: !elem x skipped-packages) (attrNames ngipkgs);
  update-commands = lib.concatMapStringsSep "\n" (package: ''
    if ! nix-update --flake --use-update-script "${package}" "$@"; then
      echo "${package}" >> "$TMPDIR/failed_updates.txt"
    fi
  '') update-packages;
in
# nix-shell --run update-all
writeShellApplication {
  name = "update-all";
  runtimeInputs = [ nix-update ];
  text = ''
    TMPDIR=$(mktemp -d)

    echo -n> "$TMPDIR/failed_updates.txt"

    ${update-commands}

    if [ -s "$TMPDIR/failed_updates.txt" ]; then
    echo -e "\nFailed to update the following packages:"
    cat "$TMPDIR/failed_updates.txt"
    else
    echo "All packages updated successfully!"
    fi
  '';
}
