# Install all curated apps
som-install: som-install-flatpaks som-install-brews som-install-appimages

# Install only Flatpaks
som-install-flatpaks:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Installing Flatpaks..."
    xargs -a <(curl --retry 3 -sL https://raw.githubusercontent.com/endegraaf/scaling-octo-meme/main/repo_files/flatpaks) flatpak --system -y install
    echo "Flatpaks installation complete."

# Install only Homebrews
som-install-brews:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Installing Homebrews..."
    xargs -a <(curl --retry 3 -sL https://raw.githubusercontent.com/endegraaf/scaling-octo-meme/main/repo_files/brews) brew install
    echo "Homebrews installation complete."

# Install only AppImages
som-install-appimages:
    #!/usr/bin/env bash
    set -euo pipefail

    DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-${HOME}/Downloads}"
    [ ! -d "$DOWNLOAD_DIR" ] && DOWNLOAD_DIR="$HOME"

    # Install Gear Lever if not installed
    flatpak list | grep -q "it.mijorus.gearlever" || flatpak --system -y install it.mijorus.gearlever

    while IFS=, read -r name url; do
      [ -z "$name" -o -z "$url" ] && continue
      echo "Processing $name..."

      # Skip if installed
      if flatpak run it.mijorus.gearlever --list-installed | grep -qi "${name}.appimage"; then
        echo "$name already installed"
        continue
      fi

      # Handle GitHub wildcards
      if [[ "$url" =~ github.com/([^/]+/[^/]+)/releases/download/[^/]*/([^/]*) ]] && [[ "$url" == *"*"* ]]; then
        pattern="$(echo "${BASH_REMATCH[2]}" | sed 's/\./\\./g' | sed 's/\*/.*/g')"
        # Try each release until we find one with an AppImage
        url=""
        while read -r release_url; do
          if [[ "$release_url" =~ $pattern ]]; then
            url="$release_url"
            break
          fi
        done < <(curl --retry 3 -sL "https://api.github.com/repos/${BASH_REMATCH[1]}/releases" | jq -r ".[].assets[].browser_download_url")
        [ -z "$url" ] && {
          echo "No release found for $name"
          continue
        }
      fi

      # Handle JSON API responses (like cursor.com API)
      if [[ "$url" != http*github.com* ]]; then
        response=$(curl --retry 3 -sL "$url")
        if echo "$response" | jq -e '.downloadUrl' >/dev/null 2>&1; then
          url=$(echo "$response" | jq -r '.downloadUrl')
          echo "  Found download URL in JSON: $url"
        elif echo "$response" | jq -e '.download_url' >/dev/null 2>&1; then
          url=$(echo "$response" | jq -r '.download_url')
          echo "  Found download URL in JSON: $url"
        fi
      fi

      # Download and install
      appimage="$DOWNLOAD_DIR/${name}.appimage"
      if aria2c --dir="$(dirname "$appimage")" --out="$(basename "$appimage")" --max-tries=3 --connect-timeout=30 "$url" && chmod +x "$appimage" && flatpak run it.mijorus.gearlever --integrate "$appimage" -y; then
        echo "$name installed successfully"
      else
        echo "Failed to install $name"
      fi
      rm -f "$appimage"
    done < <(curl --retry 3 -sL https://raw.githubusercontent.com/endegraaf/scaling-octo-meme/main/repo_files/appimages)
    echo "AppImages installation complete."


# Restart Bluetooth to fix issues
som-fix-bt:
    #!/usr/bin/env bash
    set -euo pipefail
    trap '[[ $BASH_COMMAND != echo* ]] && echo "+ $BASH_COMMAND"' DEBUG

    echo "Fixing Bluetooth..."
    sudo rfkill unblock all
    sudo rmmod btusb
    sudo modprobe btusb
    echo "Bluetooth fix complete."


# Clean up old packages and Docker/Podman images and volumes
som-clean:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Cleaning up system..."
    docker system prune -af
    podman system prune -af
    flatpak uninstall --unused
    rpm-ostree cleanup -bm
    sudo docker system prune -af
    sudo podman system prune -af


# Create a Fedora 43 development toolbox for building/compiling Linux software
som-setup-devbox:
    #!/usr/bin/env bash
    set -euo pipefail

    TOOLBOX_NAME="devbox"
    FEDORA_IMAGE="registry.fedoraproject.org/fedora-toolbox:43"

    # Skip if already exists
    if toolbox list --containers | grep -q "^${TOOLBOX_NAME}$"; then
        echo "Toolbox '${TOOLBOX_NAME}' already exists. Enter it with: toolbox enter ${TOOLBOX_NAME}"
        exit 0
    fi

    echo "Creating Fedora 43 dev toolbox..."
    toolbox create --image "${FEDORA_IMAGE}" --container "${TOOLBOX_NAME}"

    echo "Installing build tools inside toolbox..."
    toolbox run --container "${TOOLBOX_NAME}" bash -c "
        sudo dnf install -y \
          # Core build tools
          @development-tools \
          gcc gcc-c++ clang llvm \
          cmake ninja-build meson \
          make automake autoconf libtool \
          pkg-config \
          git \
          # Debuggers & profilers
          gdb valgrind strace ltrace \
          # Common dev libs
          python3-devel \
          openssl-devel \
          zlib-devel \
          libffi-devel \
          readline-devel \
          sqlite-devel \
          bzip2-devel \
          xz-devel \
          cups-devel \
          # Image libs
          libjpeg-turbo-devel \
          libpng-devel \
          libtiff-devel \
          exiv2-devel \
          lcms2-devel \
          cfitsio-devel \
          # Qt6
          qt6-qtbase-devel \
          qt6-qtbase-private-devel \
          qt6-qtsvg-devel \
          qt6-qtmultimedia-devel \
          qt6-qtwayland-devel \
          # Wayland
          wayland-devel \
          wayland-protocols-devel \
          # KDE Frameworks 6
          extra-cmake-modules \
          kf6-kio-devel \
          kf6-ki18n-devel \
          kf6-kparts-devel \
          kf6-kwindowsystem-devel \
          kf6-kiconthemes-devel \
          kf6-knotifications-devel \
          kf6-kguiaddons-devel \
          kf6-kwidgetsaddons-devel \
          kf6-kcrash-devel \
          kf6-kitemmodels-devel \
          kf6-baloo-devel \
          kf6-purpose-devel \
          kf6-kdoctools-devel \
          plasma-activities-devel \
          # Annotation support
          kimageannotator-qt6-devel \
          kcolorpicker-qt6-devel \
        && sudo dnf clean all
    "

    echo ""
    echo "✅ Dev toolbox ready! Enter it with:"
    echo "   toolbox enter ${TOOLBOX_NAME}"
