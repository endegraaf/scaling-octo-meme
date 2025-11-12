## 1. BUILD ARGS
# See list here: https://github.com/orgs/ublue-os/packages?repo_name=main

### 2. SOURCE IMAGE
FROM ghcr.io/ublue-os/bazzite-dx-nvidia:latest

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

### 3. MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

COPY / /

RUN ./build.sh

