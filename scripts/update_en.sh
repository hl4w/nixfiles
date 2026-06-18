#!/usr/bin/env bash
# Author: Silas Zhang (2026)
# shellcheck shell=bash
# NixOS compatibility: /usr/bin/env may not exist in installer environment
if [ -z "$BASH_VERSION" ]; then
    if [ -x /run/current-system/sw/bin/bash ]; then
        exec /run/current-system/sw/bin/bash "$0" "$@"
    elif ls /nix/store/*-bash*/bin/bash 2>/dev/null | head -n 1 | grep -q .; then
        exec "$(ls /nix/store/*-bash*/bin/bash | head -n 1)" "$0" "$@"
    elif [ -x /bin/bash ]; then
        exec /bin/bash "$0" "$@"
    elif [ -x /usr/bin/bash ]; then
        exec /usr/bin/bash "$0" "$@"
    fi
    echo "Error: bash not found" >&2
    exit 1
fi
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -H, --hostname      Specify hostname (default: current hostname)"
    echo
    echo "Examples:"
    echo "  $0"
    echo "  $0 -H my-desktop"
    exit 0
}

# Defaults
TARGET_HOSTNAME="$HOSTNAME"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -H|--hostname)
            TARGET_HOSTNAME="$2"
            shift 2
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

info "=========================================="
info "        HL4W NixOS Update Utility"
info "=========================================="
echo

info "Updating flake inputs..."
nix flake update

info "Building system configuration..."
if [ -n "$TARGET_HOSTNAME" ]; then
    info "Target host: $TARGET_HOSTNAME"
    nix build .#"$TARGET_HOSTNAME"
else
    warn "No hostname specified, using default configuration"
    nix build .#desktop
fi

echo
info "=========================================="
info "           Update Complete!"
info "=========================================="
echo
info "Next steps to deploy the update:"
echo "  sudo nixos-rebuild switch --flake .#$TARGET_HOSTNAME"
echo "  home-manager switch --flake .#$USER@$TARGET_HOSTNAME"