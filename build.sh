#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages


# vscode rpm
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null


# this installs a package from fedora repos
rpm-ostree install screen filezilla krita kdenlive syncthing obs-studio vlc chromium syncthing jetbrains-mono-fonts-all bat netcat

# this would install a package from rpmfusion
# rpm-ostree install vlc

rpm-ostree install code



#### Example for enabling a System Unit File

systemctl enable podman.socket
