#!/usr/bin/bash
# source https://github.com/m2Giles/m2os/blob/main/desktop-packages.sh

set -ouex pipefail


FEDORA_MAJOR_VERSION=$(rpm -E %fedora)

echo "Add COPR repos for F${FEDORA_MAJOR_VERSION}"

# Fonts
curl --retry 3 -Lovvv /etc/yum.repos.d/atim-ubuntu-fonts-fedora-"${FEDORA_MAJOR_VERSION}".repo \
    https://copr.fedorainfracloud.org/coprs/atim/ubuntu-fonts/repo/fedora-"${FEDORA_MAJOR_VERSION}"/atim-ubuntu-fonts-fedora-"${FEDORA_MAJOR_VERSION}".repo

curl --retry 3 -Lo /etc/yum.repos.d/_copr_che-nerd-fonts-"${FEDORA_MAJOR_VERSION}".repo \
    https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/repo/fedora-"${FEDORA_MAJOR_VERSION}"/che-nerd-fonts-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Kvmfr module
curl --retry 3 -Lo /etc/yum.repos.d/hikariknight-looking-glass-kvmfr-fedora-"${FEDORA_MAJOR_VERSION}".repo \
    https://copr.fedorainfracloud.org/coprs/hikariknight/looking-glass-kvmfr/repo/fedora-"${FEDORA_MAJOR_VERSION}"/hikariknight-looking-glass-kvmfr-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Podman-bootc
curl --retry 3 -Lo /etc/yum.repos.d/gmaglione-podman-bootc-fedora-"${FEDORA_MAJOR_VERSION}".repo \
    https://copr.fedorainfracloud.org/coprs/gmaglione/podman-bootc/repo/fedora-"${FEDORA_MAJOR_VERSION}"/gmaglione-podman-bootc-fedora-"${FEDORA_MAJOR_VERSION}".repo

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
    emacs
    filezilla
    genisoimage
    genisoimage
    git-credential-libsecret
    git-credential-libsecret
    git-credential-oauth
    google-noto-fonts-all
    jetbrains-mono-fonts-all
    kdenlive
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
    powerline-fonts
    python3-pip
    qemu
    qemu-user-binfmt
    qemu-user-static
    syncthing
    syncthing
    virt-v2v
    vlc
    ydotool
    ydotool
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

pip install powerline-shell

# Call other Scripts
/ctx/desktop-defaults.sh
/ctx/enable-services.sh
