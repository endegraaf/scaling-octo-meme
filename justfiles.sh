#!/usr/bin/bash
# source https://github.com/m2Giles/m2os/blob/main/desktop-defaults.sh
set -eou pipefail

echo "Adding Custom OS just recipes"
echo "import \"/usr/share/scaling-octo-meme/just/scaling-octo-meme.just\"" >>/usr/share/ublue-os/justfile
echo ""