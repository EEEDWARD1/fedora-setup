#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "ERROR on line $LINENO: $BASH_COMMAND" >&2' ERR

# ==========================================
# 02 - Fedora Repository Configuration
# ==========================================

echo "======================================"
echo " Fedora Repository Configuration"
echo "======================================"

# 1. Verify Fedora Environmentnex
if [[ ! -f /etc/fedora-release ]]; then
    echo "This script is intended for Fedora Linux."
    exit 1
fi

FEDORA_VERSION=$(rpm -E %fedora)
echo "Detected Fedora version: $FEDORA_VERSION"

# 2. Ensure Sudo Access
echo "[1/4] Checking administrator privileges..."
sudo -v

# 3. Install RPM Fusion Repositories
echo "[2/4] Configuring RPM Fusion..."

if ! rpm -q rpmfusion-free-release &>/dev/null; then
    sudo dnf install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm"
else
    echo "RPM Fusion Free already installed."
fi

if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
    sudo dnf install -y \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm"
else
    echo "RPM Fusion Nonfree already installed."
fi

# 4. Enable OpenH264
echo "[3/4] Enabling Cisco OpenH264..."

sudo dnf config-manager setopt \
    fedora-cisco-openh264.enabled=1

# 5. Verify Repositories
echo "[4/4] Verifying repositories..."

dnf repolist | grep rpmfusion

echo "======================================"
echo " Repository configuration complete!"
echo "======================================"