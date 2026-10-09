#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "ERROR on line $LINENO: $BASH_COMMAND" >&2' ERR

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

SCRIPTS=(
    "01-system.sh"
    "02-repositories.sh"
    "03-multimedia.sh"
    "04-development.sh"
    "05-docker.sh"
    "06-applications.sh"
    "07-services.sh"
)

echo "======================================"
echo " Fedora Workstation Setup"
echo "======================================"

for script in "${SCRIPTS[@]}"; do

    echo ""
    echo "Executing: $script"
    echo ""

    bash "$SCRIPT_DIR/scripts/$script"

    echo "Completed: $script"

done

echo ""
echo "======================================"
echo " Fedora setup completed!"
echo "======================================"