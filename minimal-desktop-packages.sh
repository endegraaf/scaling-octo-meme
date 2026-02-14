#!/usr/bin/bash
# source https://github.com/m2Giles/m2os/blob/main/desktop-packages.sh

set -ouex pipefail

# Layered Applications
LAYERED_PACKAGES=(
    firefox
)
dnf5 install -y "${LAYERED_PACKAGES[@]}"
