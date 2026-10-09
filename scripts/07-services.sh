#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "ERROR on line $LINENO: $BASH_COMMAND" >&2' ERR

# ==========================================
# 07 - Fedora Services Configuration
# ==========================================

echo "======================================"
echo " Fedora Services Configuration"
echo "======================================"

# 1. Verify Fedora Environment
if [[ ! -f /etc/fedora-release ]]; then
    echo "This script requires Fedora Linux."
    exit 1
fi

# Ensure script runs as normal user
if [[ "$EUID" -eq 0 ]]; then
    echo "ERROR: Do not run this script as root."
    echo "Run it as your normal user."
    exit 1
fi

# 2. Ensure Sudo Access
echo "[1/6] Checking administrator privileges..."
sudo -v

# 3. Configure Tailscale Repository
echo "[2/6] Configuring Tailscale repository..."

if [[ ! -f /etc/yum.repos.d/tailscale.repo ]]; then

    sudo dnf config-manager addrepo \
        --from-repofile \
        https://pkgs.tailscale.com/stable/fedora/tailscale.repo

else
    echo "Tailscale repository already configured."
fi

# 4. Install Tailscale
echo "[3/6] Installing Tailscale..."

sudo dnf install -y tailscale

# Enable Tailscale daemon
sudo systemctl enable --now tailscaled

if sudo systemctl is-active --quiet tailscaled; then
    echo "Tailscale daemon is running."
else
    echo "ERROR: Tailscale daemon failed to start."
    exit 1
fi

# 5. Install OneDrive
echo "[4/6] Installing OneDrive client..."

sudo dnf install -y onedrive

# Check if OneDrive user service exists
if systemctl --user list-unit-files \
    onedrive.service --no-legend | grep -q '^onedrive.service'; then

    echo "OneDrive user service is available."

    # Enable at login but do not start before authentication
    systemctl --user enable onedrive.service

else
    echo "WARNING: OneDrive user service not found."
fi

# 6. Verify Services
echo "[5/6] Verifying installations..."

echo "Tailscale:"
tailscale version

echo "OneDrive:"
onedrive --version

echo "Tailscale service:"
systemctl is-enabled tailscaled

echo "OneDrive service:"
systemctl --user is-enabled onedrive.service || true

# 7. Authentication Instructions
echo "[6/6] Checking authentication..."

if tailscale status &>/dev/null; then
    echo "Tailscale is connected."
else
    echo "Tailscale requires authentication."
    echo "Run: sudo tailscale up"
fi

echo ""
echo "OneDrive requires initial authentication."
echo "Run: onedrive"
echo "Then test: onedrive --sync --verbose"
echo "Finally: systemctl --user start onedrive"

echo "======================================"
echo " Services configuration complete!"
echo "======================================"