#!/usr/bin/bash
set -ouex pipefail

ZED_URL="https://zed.dev/api/releases/stable/latest/zed-linux-x86_64.tar.gz"
TMP_FILE="/tmp/zed.tar.gz"

# 1. Determine the correct writable /opt location
if [ -L "/opt" ]; then
    # On Atomic, /opt is a symlink to /var/opt
    ZED_DEST="/var/opt/zed.app"
else
    ZED_DEST="/opt/zed.app"
fi

echo "Installing Zed Editor to $ZED_DEST..."

# 2. Download and Extract
curl -Lo "$TMP_FILE" "$ZED_URL"
mkdir -p "$ZED_DEST"
tar -xzf "$TMP_FILE" -C "$ZED_DEST" --strip-components=1

# 3. Handle Binary Symlink
# Ensure /usr/local/bin exists. On some Atomic setups, 
# /usr/local is a symlink to /var/usrlocal.
mkdir -p /usr/local/bin
ln -sf "$ZED_DEST/bin/zed" /usr/local/bin/zed

# 4. Desktop Integration
# If /usr/share/applications is read-only (standard Atomic), 
# this part only works during a 'build' phase (like a Containerfile).
# If running on a live system, use /var/home/$USER/.local/share/applications/ instead.
DESKTOP_FILE="/usr/share/applications/dev.zed.Zed.desktop"

# Check if we can write to /usr/share (Build time) or need a local path
if [ ! -w "/usr/share/applications" ]; then
    echo "Warning: /usr/share is read-only. Attempting user-local installation."
    DESKTOP_DIR="$HOME/.local/share/applications"
    ICON_BASE="$HOME/.local/share/icons/hicolor"
    mkdir -p "$DESKTOP_DIR"
else
    DESKTOP_DIR="/usr/share/applications"
    ICON_BASE="/usr/share/icons/hicolor"
fi

FINAL_DESKTOP="$DESKTOP_DIR/dev.zed.Zed.desktop"
cp "$ZED_DEST/share/applications/zed.desktop" "$FINAL_DESKTOP"

# Use sed to point the Desktop file to the correct executable path
sed -i "s|Exec=zed|Exec=$ZED_DEST/libexec/zed-editor|g" "$FINAL_DESKTOP"
sed -i "s|Icon=zed|Icon=zed|g" "$FINAL_DESKTOP"

# 5. Icon Deployment
for size in 512x512 1024x1024; do
    ICON_DIR="$ICON_BASE/$size/apps"
    mkdir -p "$ICON_DIR"
    cp "$ZED_DEST/share/icons/hicolor/$size/apps/zed.png" "$ICON_DIR/zed.png"
done

# Cleanup
rm "$TMP_FILE"
echo "Zed installed successfully!"

