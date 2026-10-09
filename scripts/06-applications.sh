#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "ERROR on line $LINENO: $BASH_COMMAND" >&2' ERR

# ==========================================
# 06 - Fedora Desktop Applications
# ==========================================

echo "======================================"
echo " Fedora Desktop Applications"
echo "======================================"

# 1. Verify Fedora Environment
if [[ ! -f /etc/fedora-release ]]; then
    echo "This script requires Fedora Linux."
    exit 1
fi

# 2. Ensure Sudo Access
echo "[1/7] Checking administrator privileges..."
sudo -v

# 3. Install Flatpak
echo "[2/7] Installing Flatpak..."

sudo dnf install -y flatpak

# 4. Configure Flathub
echo "[3/7] Configuring Flathub..."

# Configure system-wide Flathub
sudo flatpak remote-add --system --if-not-exists \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# Remove Fedora's potential Flathub application filter
sudo flatpak remote-modify --system \
    --no-filter \
    --enable flathub

# 5. Install Flatpak Applications
echo "[4/7] Installing desktop applications..."

FLATPAK_APPS=(
    org.videolan.VLC
    com.spotify.Client
    md.obsidian.Obsidian
)

for app in "${FLATPAK_APPS[@]}"; do

    if flatpak info --system "$app" &>/dev/null; then
        echo "$app is already installed."
    else
        echo "Installing $app..."

        sudo flatpak install -y --noninteractive \
            --system flathub "$app"
    fi

done

# 6. Install Google Chrome
echo "[5/7] Installing Google Chrome..."

sudo dnf install -y \
    fedora-workstation-repositories

sudo dnf config-manager setopt \
    google-chrome.enabled=1

sudo dnf install -y google-chrome-stable

# 7. Install Fonts
echo "[6/7] Installing fonts..."

sudo dnf install -y \
    jetbrains-mono-fonts \
    google-roboto-fonts \
    google-inter-fonts \
    google-noto-sans-fonts \
    google-rubik-fonts \
    google-lato-fonts

# Rebuild font cache
fc-cache -f

# 8. Install LaTeX
echo "[7/7] Installing LaTeX..."

sudo dnf install -y \
    texstudio \
    texlive-scheme-full

# 9. Verify Installation
echo "======================================"
echo " Verifying applications"
echo "======================================"

echo "Flatpak:"
flatpak --version

echo "Installed Flatpak applications:"
flatpak list --system --app

echo "Google Chrome:"
google-chrome --version

echo "JetBrains Mono:"
fc-match "JetBrains Mono"

echo "LaTeX:"
pdflatex --version | head -n 1

echo "======================================"
echo " Desktop applications configured!"
echo "======================================"