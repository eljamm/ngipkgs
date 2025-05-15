#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck disable=SC2034
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [options]

Create a temporary shell environment containing specified applications.

Available options:

-a, --apps            Comma separated list of applications to enable on PATH.
                      Example: gdal,qgis
EOF
    exit
}

app_shell_nix_dir=${APP_SHELL_NIX_DIR:-.}

verbose_msg() {
    if [ -n "${verbose-}" ]; then
        echo >&2 -e "INFO: ${1-}"
    fi
}

msg() {
    echo >&2 -e "${1-}"
}

die() {
    local msg=$1
    local code=${2-1} # default exit status 1
    msg "$msg"
    exit "$code"
}

parse_params() {
    while :; do
        case "${1-}" in
        -h | --help) usage ;;
        -v | --verbose) verbose=1 ;;
        -a | --apps)
            apps="${2-}"
            shift
            ;;
        -?*) die "Unknown option: $1" ;;
        *) break ;;
        esac
        shift
    done

    return 0
}
parse_params "$@"

# Create app shell command
cmd="nix build --print-out-paths --no-link"

if [ -n "${verbose-}" ]; then
    cmd+=" --print-build-logs --show-trace"
fi

cmd+=" --file ${app_shell_nix_dir}/app-shell.nix"

if [ -n "${nixpkgs-}" ]; then
    cmd+=" --argstr nixpkgs $nixpkgs"
fi

if [ -n "${command-}" ]; then
    c=(--argstr command \'"${command[*]}"\')
    cmd+=" "
    cmd+=${c[*]}
fi

# Activate shell
verbose_msg "nix command: $cmd"
activate=$(eval "$cmd")
verbose_msg "activate script: $activate"
$activate
