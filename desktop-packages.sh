#!/usr/bin/bash
# source https://github.com/m2Giles/m2os/blob/main/build_files/desktop-packages.sh

set -ouex pipefail

ZED_URL="https://zed.dev/api/releases/stable/latest/zed-linux-x86_64.tar.gz"
ZED_DEST="/opt/zed.app"
TMP_FILE="/tmp/zed.tar.gz"

# 1. Use the native COPR plugin instead of manual curls
# Syntax: dnf copr enable <user/project> -y
REPOS=(
    "atim/ubuntu-fonts"
    "che/nerd-fonts"
    "hikariknight/looking-glass-kvmfr"
    "gmaglione/podman-bootc"
    "phracek/PyCharm"
)

echo "Enabling COPR repositories..."
for repo in "${REPOS[@]}"; do
    dnf copr enable "$repo" -y
done

# 2. External repos (non-COPR)
echo "Adding external repositories..."
# Direct download to the repos directory (Works for DNF and DNF5)
curl -sLo /etc/yum.repos.d/mullvad.repo https://repository.mullvad.net/rpm/stable/mullvad.repo

# VSCode because it's still better for a lot of things
tee /etc/yum.repos.d/vscode.repo <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

dnf5 group install -y virtualization

# Layered Applications
LAYERED_PACKAGES=(
    bat
    cascadia-code-fonts
    cascadia-fonts-all
    chromium
    code
    filezilla
    firefox
    genisoimage
    git-credential-libsecret
    git-credential-oauth
    google-noto-fonts-all
    jetbrains-mono-fonts-all
    kdenlive
    konsole
    krita
    libvirt
    libvirt-nss
    nerd-fonts
    obs-studio
    p7zip
    podman-bootc
    podman-compose
    podman-machine
    podmansh
    podman-tui
    powerline
    powerline-fonts
    python3-pip
    ubuntu-family-fonts
    qemu
    qemu-user-binfmt
    qemu-user-static
    syncthing
    virt-v2v
    vlc
    ydotool
)
dnf5 install -y "${LAYERED_PACKAGES[@]}"

rpm-ostree install -y pycharm-community

echo "Installing Zed Editor..."

# 1. Download and Extract
curl -Lo "$TMP_FILE" "$ZED_URL"
mkdir -p "$ZED_DEST"
tar -xzf "$TMP_FILE" -C "$ZED_DEST" --strip-components=1

# 2. Set Permissions and Symlink
chown -R root:root "$ZED_DEST"
ln -sf "$ZED_DEST/bin/zed" /usr/local/bin/zed

# 3. Desktop Integration
DESKTOP_FILE="/usr/share/applications/dev.zed.Zed.desktop"
cp "$ZED_DEST/share/applications/zed.desktop" "$DESKTOP_FILE"

# Use sed to point the Desktop file to the correct executable path
sed -i "s|Exec=zed|Exec=$ZED_DEST/libexec/zed-editor|g" "$DESKTOP_FILE"
sed -i "s|Icon=zed|Icon=zed|g" "$DESKTOP_FILE"

# 4. Icon Deployment (Looping to avoid repetition)
for size in 512x512 1024x1024; do
    ICON_DIR="/usr/share/icons/hicolor/$size/apps"
    mkdir -p "$ICON_DIR"
    cp "$ZED_DEST/share/icons/hicolor/$size/apps/zed.png" "$ICON_DIR/"
done

# Cleanup
rm "$TMP_FILE"
echo "Zed installed successfully!"

dnf5 clean all

# Call other Scripts
./desktop-defaults.sh
./enable-services.sh
