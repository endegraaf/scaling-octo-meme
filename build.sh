#!/bin/bash

set -ouex pipefail

mkdir -p /var/lib/alternatives

# My Packages
/ctx/desktop-packages.sh


ostree container commit

