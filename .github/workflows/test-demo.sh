#!/usr/bin/env bash

set -eo pipefail

install_nix() {
    # Debian/Ubuntu
    if echo "$DISTRO" | grep --quiet "debian\|ubuntu"; then
        apt update
        apt install --yes curl git jq nix
    # Archlinux
    elif echo "$DISTRO" | grep --quiet archlinux; then
        pacman --sync --refresh --noconfirm curl git jq nix
    # Other
    else
        echo "ERROR: Unknown distro. Exiting ..."
        exit 1
    fi
}

nix_version() {
    function fver { printf '%d%02d%02d' "${1}" "${2:-0}" "${3:-0}"; }
    echo $(fver $(nix --version | grep -oP '([0-9]+\.?)+' | sed 's/\./ /g'))
}

nix_build() {
    local file="$1" # points to a project's default.nix
    local additional_args=()

    # Nix versions < 2.24 don't work for our use case due to regression in
    # closureInfo.
    # https://github.com/NixOS/nix/issues/6820
    if [ "$(nix_version)" -ge 22400 ]; then
        echo "Using Nix installed by Linux package manager"
    else
        echo "Using Nix from Nixpkgs unstable"

        nixpkgs_revision=$(
            nix-instantiate --eval --attr sources.nixpkgs.rev /ngipkgs |
                jq --raw-output
        )
        NIXPKGS="https://github.com/NixOS/nixpkgs/archive/$nixpkgs_revision.tar.gz"

        additional_args=(--include "nixpkgs=$NIXPKGS")
    fi

    nix-shell "${additional_args[@]}" --run "nix-build --arg ngipkgs 'import /ngipkgs {}' '$file'"
}

test_demo() {
    local name="$1"

    if [[ "$name" == "Cryptpad" ]]; then
        curl --retry 10 --retry-all-errors --fail localhost:9000 | grep CryptPad
    elif [[ "$name" == "mitmproxy" ]]; then
        mitmproxy --version
    else
        echo "ERROR: Demo for $name not found. Exiting ..."
        exit 1
    fi
}

demo_projects() {
    projects=()

    for dir in /overview/project/*/; do
        if [[ -f "${dir}default.nix" ]]; then
            name=$(basename "$dir")
            projects+=("$name")
        fi
    done

    echo ${projects[@]}
}

echo -e "\n-> Installing Nix ..."
install_nix

echo -e "\n-> Nix version ..."
echo "Nix version: $(nix_version)"

for project in $(demo_projects); do
    echo -e "\n-> Testing $project ..."

    echo -e "\n---> Building VM ..."
    nix_build /overview/project/$project/default.nix

    echo -e "\n---> Launching VM ..."
    ./result &

    echo -e "\n---> Running test ..."
    test_demo "$project"
done
