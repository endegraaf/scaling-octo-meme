#!/usr/bin/bash
# source https://github.com/m2Giles/m2os/blob/main/desktop-packages.sh

set -ouex pipefail

COPR_URL="https://copr.fedorainfracloud.org/coprs"

FEDORA_MAJOR_VERSION=$(rpm -E %fedora)

echo "Add COPR repos for F${FEDORA_MAJOR_VERSION}"

# Fonts
curl --retry 3 -L  \
    $COPR_URL/atim/ubuntu-fonts/repo/fedora-"${FEDORA_MAJOR_VERSION}"/atim-ubuntu-fonts-fedora-"${FEDORA_MAJOR_VERSION}".repo \
    -o /etc/yum.repos.d/ericdegraaf-"${FEDORA_MAJOR_VERSION}".repo


# Layered Applications
LAYERED_PACKAGES=(
    firefox
)
dnf5 install -y "${LAYERED_PACKAGES[@]}"
