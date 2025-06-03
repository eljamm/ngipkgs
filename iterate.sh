#!/bin/env bash

export DISTRO="archlinux:latest"

docker run \
    --rm -it \
    --privileged \
    --volume ./result/project/Cryptpad/default.nix:/default.nix \
    --volume ./result:/overview \
    --volume "$(pwd):/ngipkgs" \
    --env DISTRO="$DISTRO" \
    "$DISTRO" \
    /bin/bash

# -c "bash /ngipkgs/.github/workflows/test-demo.sh"
