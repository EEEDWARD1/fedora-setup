#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "ERROR on line $LINENO: $BASH_COMMAND" >&2' ERR

# ==========================================
# 05 - Fedora Docker Configuration
# ==========================================

echo "======================================"
echo " Fedora Docker Configuration"
echo "======================================"

# 1. Verify Fedora Environment
if [[ ! -f /etc/fedora-release ]]; then
    echo "This script requires Fedora Linux."
    exit 1
fi

# 2. Ensure Sudo Access
echo "[1/6] Checking administrator privileges..."
sudo -v

# 3. Check Existing Docker Installation
echo "[2/6] Checking Docker installation..."

if rpm -q docker-ce &>/dev/null; then
    echo "Docker Engine already installed."
else
    # Check for conflicting packages
    CONFLICTING_PACKAGES=(
        docker
        docker-client
        docker-client-latest
        docker-common
        docker-latest
        docker-latest-logrotate
        docker-logrotate
        docker-selinux
        docker-engine-selinux
        docker-engine
    )

    INSTALLED_CONFLICTS=()

    for package in "${CONFLICTING_PACKAGES[@]}"; do
        if rpm -q "$package" &>/dev/null; then
            INSTALLED_CONFLICTS+=("$package")
        fi
    done

    if (( ${#INSTALLED_CONFLICTS[@]} > 0 )); then
        echo "Conflicting packages detected:"
        printf ' - %s\n' "${INSTALLED_CONFLICTS[@]}"
        echo "Remove these packages manually before proceeding."
        exit 1
    fi
fi

# 4. Configure Docker Repository
echo "[3/6] Configuring Docker repository..."

if [[ ! -f /etc/yum.repos.d/docker-ce.repo ]]; then
    sudo dnf config-manager addrepo \
        --from-repofile \
        https://download.docker.com/linux/fedora/docker-ce.repo
else
    echo "Docker repository already configured."
fi

# 5. Install Docker Packages
echo "[4/6] Installing Docker Engine..."

sudo dnf install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# 6. Enable Docker Service
echo "[5/6] Enabling Docker services..."

sudo systemctl enable --now docker
sudo systemctl enable --now containerd

# 7. Verify Docker Installation
echo "[6/6] Verifying Docker installation..."

docker --version
docker compose version
docker buildx version

if sudo systemctl is-active --quiet docker; then
    echo "Docker service is running."
else
    echo "ERROR: Docker service is not running."
    exit 1
fi

echo "Running Docker test container..."

sudo docker run --rm hello-world

echo "======================================"
echo " Docker configuration complete!"
echo "======================================"