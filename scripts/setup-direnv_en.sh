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

confirm() {
    if [ "$NON_INTERACTIVE" = "true" ]; then
        return 0
    fi
    read -p "$1 (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -y, --yes           Non-interactive mode, auto-confirm all prompts"
    exit 0
}

# Defaults
NON_INTERACTIVE="false"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -y|--yes)
            NON_INTERACTIVE="true"
            shift
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

info "=========================================="
info "      HL4W Direnv Setup Utility"
info "=========================================="
echo

info "Initializing direnv..."
if ! command -v direnv &> /dev/null; then
    warn "direnv is not installed, attempting to install..."
    nix-env -iA nixos.direnv -q
fi

info "Allowing direnv configuration for current directory..."
direnv allow

info "Configuring Shell hook..."

# Detect current shell
SHELL_NAME=$(basename "$SHELL")

case "$SHELL_NAME" in
    zsh)
        HOOK_FILE="$HOME/.zshrc"
        HOOK_LINE='eval "$(direnv hook zsh)"'
        ;;
    bash)
        HOOK_FILE="$HOME/.bashrc"
        HOOK_LINE='eval "$(direnv hook bash)"'
        ;;
    fish)
        HOOK_FILE="$HOME/.config/fish/config.fish"
        HOOK_LINE='direnv hook fish | source'
        ;;
    *)
        warn "Unknown shell: $SHELL_NAME"
        info "Please manually add direnv hook to your shell configuration"
        exit 0
        ;;
esac

# Check if hook already exists
if grep -q "direnv hook" "$HOOK_FILE" 2>/dev/null; then
    info "direnv hook already configured in $HOOK_FILE"
else
    info "Adding direnv hook to $HOOK_FILE..."
    echo "$HOOK_LINE" >> "$HOOK_FILE"
    info "direnv hook added"
fi

echo
info "=========================================="
info "           Setup Complete!"
info "=========================================="
echo
info "Please restart terminal or run the following to apply changes:"
echo "  source $HOOK_FILE"