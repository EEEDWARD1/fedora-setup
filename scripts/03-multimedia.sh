#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "ERROR on line $LINENO: $BASH_COMMAND" >&2' ERR

# ==========================================
# 03 - Fedora Multimedia Configuration
# ==========================================

echo "======================================"
echo " Fedora Multimedia Configuration"
echo "======================================"

# 1. Verify Fedora Environment
if [[ ! -f /etc/fedora-release ]]; then
    echo "This script is intended for Fedora Linux."
    exit 1
fi

# 2. Ensure Sudo Access
echo "[1/5] Checking administrator privileges..."
sudo -v

# 3. Verify RPM Fusion
echo "[2/5] Checking RPM Fusion repositories..."

if ! dnf repolist --enabled | grep -q '^rpmfusion-free '; then
    echo "ERROR: RPM Fusion Free is not enabled."
    echo "Run 02-repositories.sh first."
    exit 1
fi

# 4. Install Full FFmpeg
echo "[3/5] Installing full FFmpeg..."

if rpm -q ffmpeg-free &>/dev/null; then
    sudo dnf swap -y \
        ffmpeg-free ffmpeg --allowerasing
else
    sudo dnf install -y ffmpeg
fi

# 5. Update Multimedia Packages
echo "[4/5] Updating multimedia packages..."

sudo dnf update -y @multimedia \
    --setopt="install_weak_deps=False" \
    --exclude=PackageKit-gstreamer-plugin

# 6. Configure AMD Hardware Acceleration
echo "[5/5] Configuring AMD hardware acceleration..."

if lspci -nn 2>/dev/null | grep -Eiq \
    'VGA|3D|Display'; then

    if lspci -nn | grep -Ei \
        'VGA|3D|Display' | grep -Eiq \
        'AMD|ATI'; then

        echo "AMD GPU detected."

        sudo dnf install -y \
            mesa-va-drivers-freeworld \
            libva-utils

    else
        echo "No AMD GPU detected. Skipping AMD VA-API drivers."
    fi
else
    echo "GPU detection unavailable. Skipping driver installation."
fi

# 7. Verify Installation
echo "Checking FFmpeg..."

ffmpeg -version | head -n 1

echo "======================================"
echo " Multimedia configuration complete!"
echo "======================================"