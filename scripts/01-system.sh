#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "ERROR on line $LINENO: $BASH_COMMAND" >&2' ERR

# ==========================================
# 01 - Fedora System Preparation
# ==========================================

# 1. Verify Fedora Environment
echo "======================================"
echo " Fedora System Preparation"
echo "======================================"

if [[ ! -f /etc/fedora-release ]]; then
    echo "This script is intended to run on Fedora Linux."
    exit 1
fi

# 2. Ensure Sudo Access
echo "Detected: $(cat /etc/fedora-release)"

echo "[1/4] Checking administrator privileges..."
sudo -v

# 3. Configure DNF
echo "[2/4] Configuring DNF..."

sudo dnf install -y dnf5-plugins

sudo dnf config-manager setopt \
    max_parallel_downloads=10 \
    fastestmirror=True

dnf --dump-main-config |
    grep -E '^(max_parallel_downloads|fastestmirror) = '
    
# 4. Update Fedora
echo "[3/4] Updating system packages..."

sudo dnf upgrade --refresh -y

# 5. Install basic utilities
echo "[4/4] Installing essential utilities..."

sudo dnf install -y \
    curl \
    wget \
    git \
    nano \
    vim \
    unzip \
    tar \
    ca-certificates

echo "======================================"
echo " System preparation completed!"
echo "======================================"