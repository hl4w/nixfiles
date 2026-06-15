#!/bin/sh
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

confirm() {
    read -p "$1 (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -y, --yes           Auto-confirm all prompts"
    echo "  -s, --store         Only clean Nix store"
    echo "  -g, --generations   Only clean old system generations"
    echo "  -a, --all           Clean everything (default)"
    exit 0
}

# Default options
CLEAN_STORE=true
CLEAN_GENERATIONS=true
NON_INTERACTIVE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -y|--yes)
            NON_INTERACTIVE=true
            shift
            ;;
        -s|--store)
            CLEAN_GENERATIONS=false
            shift
            ;;
        -g|--generations)
            CLEAN_STORE=false
            shift
            ;;
        -a|--all)
            CLEAN_STORE=true
            CLEAN_GENERATIONS=true
            shift
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

info "=========================================="
info "         NixOS Cleanup Utility"
info "=========================================="
echo

if [ "$NON_INTERACTIVE" = false ]; then
    info "The following cleanup operations will be performed:"
    if [ "$CLEAN_STORE" = true ]; then
        echo "  - Clean unused packages from Nix store"
    fi
    if [ "$CLEAN_GENERATIONS" = true ]; then
        echo "  - Delete old system generations (keep latest 3)"
    fi
    echo
    if ! confirm "Confirm to continue?"; then
        info "Operation cancelled"
        exit 0
    fi
fi

if [ "$CLEAN_STORE" = true ]; then
    info "Cleaning Nix store..."
    nix store gc --print-roots
    info "Nix store cleanup complete"
fi

if [ "$CLEAN_GENERATIONS" = true ]; then
    info "Cleaning old system generations..."
    sudo nix-collect-garbage -d
    info "Old generations cleanup complete"
fi

info "=========================================="
info "        Cleanup complete!"
info "=========================================="
