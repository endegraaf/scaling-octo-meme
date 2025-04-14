#!/usr/bin/env bash
IMAGE=localhost/heliumos-bootc:10
    # quay.io/fedora-ostree-desktops/kinoite:42  #ghcr.io/endegraaf/scaling-octo-meme:latest

mkdir -p output
sudo podman pull ${IMAGE}
sudo podman run \
    --rm \
    -it \
    --pull=newer \
    --privileged \
    --security-opt label=type:unconfined_t \
    -v ./10/config.toml:/config.toml:ro \
    -v ./output:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    ghcr.io/centos-workstation/bootc-image-builder:latest \
    --type anaconda-iso \
    --local \
    ${IMAGE}

sudo chmod 777 ./output/bootiso/install.iso

sudo podman run \
    --rm \
    -it \
    --pull=newer \
    --privileged \
    -v ./output:/output \
    -v ./10:/10 \
    ${IMAGE} \
    bash -c '\
        dnf install -y lorax \
	&& rm -rf /images && mkdir /images \
	&& rm /output/my-boot.iso || true \
	&& cd /10/product && find . | cpio -c -o | gzip -9cv > /images/product.img && cd / \
        && mkksiso --add images --volid heliumos-boot /output/bootiso/install.iso /output/my-boot.iso'
sudo chown -R egraaf: ./output/
