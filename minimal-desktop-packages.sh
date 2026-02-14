#!/bin/bash
set -euo pipefail
#  #> dnf copr enable retrozinndev/ags 
# 1. Use the native COPR plugin instead of manual curls
# Syntax: dnf copr enable <user/project> -y
REPOS=(
    "retrozinndev/ags"
)

echo "Enabling COPR repositories..."
for repo in "${REPOS[@]}"; do
    dnf copr enable "$repo" -y
done
# Layered Applications
LAYERED_PACKAGES=(
    firefox
)
dnf5 install -y "${LAYERED_PACKAGES[@]}"
