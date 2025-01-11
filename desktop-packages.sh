#!/usr/bin/bash
# source https://github.com/m2Giles/m2os/blob/main/desktop-packages.sh

set -ouex pipefail

# VSCode because it's still better for a lot of things
tee /etc/yum.repos.d/vscode.repo <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# Layered Applications
LAYERED_PACKAGES=(
    cascadia-fonts-all
    code
    emacs
    git-credential-libsecret
    git-credential-oauth
    filezilla
    krita 
    kdenlive 
    syncthing 
    obs-studio 
    vlc 
    chromium 
    syncthing 
    jetbrains-mono-fonts-all 
    bat 
    netcat
    nerd-fonts
    podman-bootc
    podman-compose
    podman-machine
    podman-tui
    powerline-fonts
    virt-manager
    virt-viewer
    qemu-system-x86-core
    qemu
    qemu-img
    genisoimage
    p7zip
    p7zip-plugins
    google-noto-fonts-all
    cascadia-code-fonts
    git-credential-libsecret
    python3-pip
)
dnf5 install -y "${LAYERED_PACKAGES[@]}"

# Zed because why not?
curl -Lo /tmp/zed.tar.gz \
    https://zed.dev/api/releases/stable/latest/zed-linux-x86_64.tar.gz
mkdir -p /usr/lib/zed.app/
tar -xvf /tmp/zed.tar.gz -C /usr/lib/zed.app/ --strip-components=1
chown 0:0 -R /usr/lib/zed.app
ln -s /usr/lib/zed.app/bin/zed /usr/bin/zed-cli
cp /usr/lib/zed.app/share/applications/zed.desktop /usr/share/applications/dev.zed.Zed.desktop
mkdir -p /usr/share/icons/hicolor/1024x1024/apps
cp {/usr/lib/zed.app,/usr}/share/icons/hicolor/512x512/apps/zed.png
cp {/usr/lib/zed.app,/usr}/share/icons/hicolor/1024x1024/apps/zed.png
sed -i "s@Exec=zed@Exec=/usr/lib/zed.app/libexec/zed-editor@g" /usr/share/applications/dev.zed.Zed.desktop

# Emacs LSP Booster
EMACS_LSP_BOOSTER="$(curl -L https://api.github.com/repos/blahgeek/emacs-lsp-booster/releases/latest | jq -r '.assets[].browser_download_url' | grep musl.zip$)"
curl -Lo /tmp/emacs-lsp-booster.zip "$EMACS_LSP_BOOSTER"
unzip -d /usr/bin/ /tmp/emacs-lsp-booster.zip

dnf5 clean all


# Call other Scripts
/ctx/desktop-defaults.sh
/ctx/enable-services.sh
