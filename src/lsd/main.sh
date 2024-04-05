#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# shellcheck source=/dev/null
. /etc/os-release

try_install() {
    if [ -n "$(ldd /bin/ls | grep 'musl' | head -1 | cut -d ' ' -f1)" ]; then
        C_LIB="musl"
    else
        C_LIB="glibc"
    fi
    echo "Detected libc: ${C_LIB}"

    echo "Downloading lsd..."
    # This script only supports x86_64 now
    curl -sL https://github.com/lsd-rs/lsd/releases/download/v1.1.2/lsd-v1.1.2-x86_64-unknown-linux-"${C_LIB}".tar.gz | tar xvz - -C /tmp
    cd /tmp/lsd-v1.1.2-x86_64-unknown-linux-"${C_LIB}"

    echo "Installing lsd..."

    echo "Installing binary..."
    mkdir -p /usr/local/bin/
    cp lsd /usr/local/bin/lsd

    # Try lsd --version to check if the binary is working
    if ! lsd --version 1>/dev/null; then
        echo "lsd binary is not working, exiting..."
        exit 1
    fi

    echo "Installing man page..."
    mkdir -p /usr/share/man/man1/
    cp lsd.1 /usr/share/man/man1/lsd.1

    echo "Installing shell completions..."
    cd autocomplete
    mkdir -p /usr/share/bash-completion/completions/
    cp lsd.bash-completion /usr/share/bash-completion/completions/lsd
    mkdir -p /usr/share/fish/vendor_completions.d/
    cp lsd.fish /usr/share/fish/vendor_completions.d/lsd.fish
}

if type apt-get >/dev/null 2>&1; then
    apt-get install -y lsd
elif type dnf >/dev/null 2>&1; then
    dnf install -y lsd
elif type pacman >/dev/null 2>&1; then
    pacman -S --noconfirm lsd
elif type zypper >/dev/null 2>&1; then
    zypper install -y lsd
else
    echo "Unknown package manager, falling back to manual installation"
    try_install
fi

ln -s "$(which lsd)" /usr/local/bin/ls
