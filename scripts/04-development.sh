#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "ERROR on line $LINENO: $BASH_COMMAND" >&2' ERR

# ==========================================
# 04 - Fedora Development Environment
# ==========================================

echo "======================================"
echo " Fedora Development Environment"
echo "======================================"

# 1. Verify Fedora Environment
if [[ ! -f /etc/fedora-release ]]; then
    echo "This script requires Fedora Linux."
    exit 1
fi

# 2. Ensure Sudo Access
echo "[1/8] Checking administrator privileges..."
sudo -v

# 3. Install Development Toolchain
echo "[2/8] Installing development toolchain..."

sudo dnf group install -y development-tools

sudo dnf install -y \
    gcc \
    gcc-c++ \
    make \
    cmake \
    clang \
    lldb \
    ninja-build \
    pkgconf-pkg-config

# 4. Install Programming Languages
echo "[3/8] Installing programming languages..."

sudo dnf install -y \
    git \
    nodejs \
    npm \
    python3 \
    python3-pip \
    python3-virtualenv \
    dotnet-sdk-10.0

# 5. Install VS Code
echo "[4/8] Configuring Visual Studio Code..."

if [[ ! -f /etc/yum.repos.d/vscode.repo ]]; then

    sudo rpm --import \
        https://packages.microsoft.com/keys/microsoft.asc

    sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

fi

sudo dnf install -y code

# 6. Install pnpm
echo "[5/8] Installing pnpm..."

if ! command -v pnpm &>/dev/null; then
    echo "Installing pnpm..."

    # Download installer for inspection before execution.
    PNPM_INSTALLER=$(mktemp)
    curl -fsSL https://get.pnpm.io/install.sh \
        -o "$PNPM_INSTALLER"

    echo "Reviewing installer from: $PNPM_INSTALLER"
    echo "Install manually after reviewing:"
    echo "sh $PNPM_INSTALLER"
else
    echo "pnpm is already installed."
fi

# 7. Install Additional Utilities
echo "[6/8] Installing additional development utilities..."

sudo dnf install -y \
    jq \
    tree \
    htop \
    ripgrep \
    fd-find \
    7zip

# 8. Configure Git
echo "[7/8] Checking Git configuration..."

if [[ -z "$(git config --global user.name || true)" ]]; then
    echo "WARNING: Git username is not configured."
fi

if [[ -z "$(git config --global user.email || true)" ]]; then
    echo "WARNING: Git email is not configured."
fi

# 9. Verify Installations
echo "[8/8] Verifying development tools..."

git --version
node --version
npm --version
python3 --version
dotnet --version
gcc --version | head -n 1
code --version | head -n 1

echo "======================================"
echo " Development environment configured!"
echo "======================================"