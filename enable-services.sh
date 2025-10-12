#!/bin/bash

set -ouex pipefail

systemctl enable podman.socket
systemctl enable libvirtd
systemctl enable virtqemud.socket
systemctl enable mullvad-daemon
systemctl enable mullvad-early-boot-blocking
