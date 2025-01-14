#!/usr/bin/bash
# source https://github.com/m2Giles/m2os/blob/main/desktop-defaults.sh
set -eou pipefail

mkdir -p /etc/xdg/autostart
mkdir -p /etc/environment.d


tee /etc/locale.conf<<'EOF'
LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LC_NUMERIC=en_US.UTF-8
LC_TIME=en_US.UTF-8
LC_COLLATE=en_US.UTF-8
LC_MONETARY=en_US.UTF-8
LC_MESSAGES=en_US.UTF-8
LC_PAPER=en_US.UTF-8
LC_NAME=en_US.UTF-8
LC_ADDRESS=en_US.UTF-8
LC_TELEPHONE=en_US.UTF-8
LC_MEASUREMENT=en_US.UTF-8
LC_IDENTIFICATION=en_US.UTF-8
LC_ALL=en_US.UTF-8
EOF

# Zed SSD
tee /tmp/zed.conf <<EOF
ZED_WINDOW_DECORATIONS=server
EOF

# Autoload SSH Identities
tee /tmp/ssh-add-identities <<'EOF'
#!/usr/bin/bash
for IDENTITY in $(find ~/.ssh/*.pub -type f); do
    if [[ -f "${IDENTITY}" ]]; then
        if [[ "${IDENTITY}" =~ sign ]]; then
            ssh-add -c "${IDENTITY:0:-4}"
        else
            ssh-add "${IDENTITY:0:-4}"
        fi
    fi
done
EOF
chmod +x /tmp/ssh-add-identities

tee /tmp/ssh-add-identities.desktop<<'EOF'
[Desktop Entry]
Exec=/usr/libexec/ssh-add-identities
Icon=application-x-shellscript
Name=ssh-add-identities
Type=Application
X-KDE-AutostartScript=true
OnlyShowIn=KDE
EOF

cp /tmp/ssh-add-identities /usr/libexec/
cp /tmp/zed.conf /etc/environment.d/
cp /tmp/ssh-add-identities.desktop /etc/xdg/autostart/

mkdir -p /usr/share/user-tmpfiles.d
tee /usr/share/user-tmpfiles.d/editor.conf <<EOF
C %h/.config/environment.d/editor.conf - - - - /usr/share/ublue-os/etc/environment.d/default-editor.conf
EOF

mkdir -p /usr/share/ublue-os/etc/environment.d
tee /usr/share/ublue-os/etc/environment.d/default-editor.conf <<EOF
EDITOR=/usr/bin/vim
EOF

