# add some DX packages. Not all. 
# source: https://github.com/ublue-os/bluefin/blob/main/build_files/dx/01-install-copr-repos-dx.sh

FEDORA_MAJOR_VERSION=$(rpm -E %fedora)

# Fonts
curl --retry 3 -Lo /etc/yum.repos.d/atim-ubuntu-fonts-fedora-"${FEDORA_MAJOR_VERSION}".repo \
    https://copr.fedorainfracloud.org/coprs/atim/ubuntu-fonts/repo/fedora-"${FEDORA_MAJOR_VERSION}"/atim-ubuntu-fonts-fedora-"${FEDORA_MAJOR_VERSION}".repo

curl --retry 3 -Lo /etc/yum.repos.d/_copr_che-nerd-fonts-"${FEDORA_MAJOR_VERSION}".repo \
    https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/repo/fedora-"${FEDORA_MAJOR_VERSION}"/che-nerd-fonts-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Kvmfr module
curl --retry 3 -Lo /etc/yum.repos.d/hikariknight-looking-glass-kvmfr-fedora-"${FEDORA_MAJOR_VERSION}".repo \
    https://copr.fedorainfracloud.org/coprs/hikariknight/looking-glass-kvmfr/repo/fedora-"${FEDORA_MAJOR_VERSION}"/hikariknight-looking-glass-kvmfr-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Podman-bootc
curl --retry 3 -Lo /etc/yum.repos.d/gmaglione-podman-bootc-fedora-"${FEDORA_MAJOR_VERSION}".repo \
    https://copr.fedorainfracloud.org/coprs/gmaglione/podman-bootc/repo/fedora-"${FEDORA_MAJOR_VERSION}"/gmaglione-podman-bootc-fedora-"${FEDORA_MAJOR_VERSION}".repo
