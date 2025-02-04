#!/bin/bash

set -ouex pipefail

mkdir -p /var/lib/alternatives


# My Packages
./desktop-packages.sh


## NOTES:
# - /var/lib/alternatives is required to prevent failure with some RPM installs
# - All RUN commands must end with ostree container commit
#   see: https://coreos.github.io/rpm-ostree/container/#using-ostree-container-commit
ostree container commit

