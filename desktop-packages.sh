#!/usr/bin/bash
# source https://github.com/m2Giles/m2os/blob/main/build_files/desktop-packages.sh

set -ouex pipefail



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
# curl -sLo /etc/yum.repos.d/mullvad.repo https://repository.mullvad.net/rpm/stable/mullvad.repo
# curl -sLo /etc/yum.repos.d/winehq.repo https://dl.winehq.org/wine-builds/fedora/43/winehq.repo

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
    gamemode
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
    podman-bootc
    podman-compose
    podman-machine
    podmansh
    podman-tui
    powerline
    powerline-fonts
    python3-pip
    steam
    ubuntu-family-fonts
    qemu
    qemu-user-binfmt
    qemu-user-static
    syncthing
    virt-v2v
    vlc
    ydotool
    kf5-plasma
    kf5-plasmaquick
    plasma-workspace
    qt5-qtdeclarative
    qt5-qtwayland
)
dnf5 install -y "${LAYERED_PACKAGES[@]}"

rpm-ostree install -y pycharm-community

dnf5 clean all

#./install-zed.sh

# Call other Scripts
./justfiles.sh
./desktop-defaults.sh
./enable-services.sh
