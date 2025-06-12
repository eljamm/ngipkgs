#!/bin/env bash

export DISTRO="archlinux:latest"
export PROJECT="mitmproxy"

docker run -it --rm \
    --privileged \
    --volume ./result:/overview \
    --volume "$(pwd):/ngipkgs" \
    -e DISTRO="$DISTRO" \
    -e PROJECT="$PROJECT" \
    "$DISTRO" \
    /bin/bash -c "bash /ngipkgs/.github/workflows/test-demo.sh"
