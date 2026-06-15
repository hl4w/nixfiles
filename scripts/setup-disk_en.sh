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

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

confirm() {
    if [ "$NON_INTERACTIVE" = "true" ]; then
        return 0
    fi
    read -p "$1 (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

usage() {
    echo "Usage: $0 [options] <disk device> <hostname> <username>"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -y, --yes           Non-interactive mode, auto-confirm all prompts"
    echo "  -c, --no-crypto     Do not use encryption (WARNING: not recommended)"
    echo "  -r, --repo-url      Specify config repository URL"
    echo "  -T, --host-type     Specify host type: desktop/laptop/server"
    echo "  -W, --wm            Specify window manager: hyprland/niri"
    echo "  -S, --shell         Specify desktop shell: dms/noctalia"
    echo ""
    echo "Examples:"
    echo "  $0 -y /dev/nvme0n1 my-desktop john"
    echo "  $0 -y -T desktop -W hyprland -S dms /dev/nvme0n1 my-desktop john"
    exit 0
}

# Defaults
NON_INTERACTIVE=false
USE_ENCRYPTION=true
REPO_URL="https://git.hl4w.com/hl4w/nixfiles26.git"
HOST_TYPE=""
WINDOW_MANAGER=""
DESKTOP_SHELL=""

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
        -c|--no-crypto)
            USE_ENCRYPTION=false
            warn "Warning: Disk encryption will not be used, this reduces system security!"
            shift
            ;;
        -r|--repo-url)
            REPO_URL="$2"
            shift 2
            ;;
        -T|--host-type)
            HOST_TYPE="$2"
            shift 2
            ;;
        -W|--wm)
            WINDOW_MANAGER="$2"
            shift 2
            ;;
        -S|--shell)
            DESKTOP_SHELL="$2"
            shift 2
            ;;
        *)
            # Positional arguments
            break
            ;;
    esac
done

# Check positional arguments
if [ $# -ne 3 ]; then
    error "Missing required arguments"
    usage
fi

DISK="$1"
HOSTNAME="$2"
USERNAME="$3"

# Show configuration summary
info "=========================================="
info "         NixOS Disk Setup Utility"
info "=========================================="
echo
info "Configuration parameters:"
info "  Disk device:       $DISK"
info "  Hostname:         $HOSTNAME"
info "  Username:         $USERNAME"
info "  Encryption:       $(if [ "$USE_ENCRYPTION" = true ]; then echo "enabled"; else echo "disabled"; fi)"
info "  Repository URL:   $REPO_URL"
if [ -n "$HOST_TYPE" ]; then
    info "  Host type:        $HOST_TYPE"
fi
if [ -n "$WINDOW_MANAGER" ]; then
    info "  Window manager:   $WINDOW_MANAGER"
fi
if [ -n "$DESKTOP_SHELL" ]; then
    info "  Desktop shell:     $DESKTOP_SHELL"
fi
echo

# Confirm operation
if ! confirm "This operation will erase ALL DATA on $DISK! Continue?"; then
    info "Operation cancelled"
    exit 0
fi

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    error "This script must be run as root"
fi

# Unmount possibly mounted partitions
info "Unmounting mounted partitions..."
umount /mnt/home 2>/dev/null || true
umount /mnt/boot 2>/dev/null || true
umount /mnt 2>/dev/null || true
swapoff /dev/mapper/vg-swap 2>/dev/null || true
cryptsetup luksClose cryptroot 2>/dev/null || true

# Create partition table
info "Creating GPT partition table..."
parted "$DISK" -- mklabel gpt

# Create EFI partition (511MB)
info "Creating EFI partition..."
parted "$DISK" -- mkpart ESP fat32 1MiB 512MiB
parted "$DISK" -- set 1 esp on

# Create root partition (remaining space)
info "Creating root partition..."
parted "$DISK" -- mkpart primary 512MiB 100%

# Get partition paths
EFI_PART="${DISK}p1"
ROOT_PART="${DISK}p2"

info "EFI partition: $EFI_PART"
info "Root partition: $ROOT_PART"

# Format EFI partition
info "Formatting EFI partition..."
mkfs.fat -F 32 "$EFI_PART"

if [ "$USE_ENCRYPTION" = true ]; then
    # Create encrypted partition
    info "Creating encrypted partition..."
    echo -n "Enter encryption password: "
    read -s CRYPT_PASSWORD
    echo
    echo ""

    echo "$CRYPT_PASSWORD" | cryptsetup luksFormat --type=luks2 "$ROOT_PART" -d -
    echo "$CRYPT_PASSWORD" | cryptsetup luksOpen "$ROOT_PART" cryptroot -d -

    # Create LVM volume group
    info "Creating LVM volume group..."
    pvcreate /dev/mapper/cryptroot
    vgcreate vg /dev/mapper/cryptroot

    ROOT_DEV="/dev/vg/root"
    HOME_DEV="/dev/vg/home"
    SWAP_DEV="/dev/vg/swap"
else
    # No encryption, format directly
    ROOT_DEV="$ROOT_PART"
    HOME_DEV="${DISK}p3"
    
    # Create home partition
    info "Creating home partition..."
    parted "$DISK" -- mkpart primary 80.5GiB 100%
    
    # Create swap file
    SWAP_DEV="/mnt/swapfile"
fi

# Create logical volumes or partitions
if [ "$USE_ENCRYPTION" = true ]; then
    info "Creating logical volumes..."
    lvcreate -L 80G vg -n root
    lvcreate -L 16G vg -n swap
    lvcreate -l 100%FREE vg -n home
else
    info "Formatting root partition..."
    mkfs.ext4 "$ROOT_DEV"
    
    info "Formatting home partition..."
    mkfs.ext4 "$HOME_DEV"
fi

# Format filesystems
info "Formatting filesystems..."
if [ "$USE_ENCRYPTION" = true ]; then
    mkfs.ext4 "$ROOT_DEV"
    mkfs.ext4 "$HOME_DEV"
    mkswap "$SWAP_DEV"
else
    mkswap "$SWAP_DEV"
fi

# Mount partitions
info "Mounting partitions..."
mount "$ROOT_DEV" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot
mkdir -p /mnt/home
mount "$HOME_DEV" /mnt/home

if [ "$USE_ENCRYPTION" = true ]; then
    swapon "$SWAP_DEV"
else
    # Create swap file
    info "Creating swap file..."
    fallocate -l 16G "$SWAP_DEV"
    chmod 600 "$SWAP_DEV"
    mkswap "$SWAP_DEV"
    swapon "$SWAP_DEV"
fi

success "Partition and mount complete!"

# Install git
info "Installing git..."
nix-env -iA nixos.git -q

# Clone config repository
info "Cloning config repository..."
mkdir -p /mnt/etc/nixos
cd /mnt/etc/nixos
git clone "$REPO_URL" .

# Run install script
info "Running install script..."
chmod +x scripts/install.sh

INSTALL_CMD="./scripts/install.sh -y -H \"$HOSTNAME\" -U \"$USERNAME\""
if [ -n "$HOST_TYPE" ]; then
    INSTALL_CMD="$INSTALL_CMD -T \"$HOST_TYPE\""
fi
if [ -n "$WINDOW_MANAGER" ]; then
    INSTALL_CMD="$INSTALL_CMD -W \"$WINDOW_MANAGER\""
fi
if [ -n "$DESKTOP_SHELL" ]; then
    INSTALL_CMD="$INSTALL_CMD -S \"$DESKTOP_SHELL\""
fi

eval "$INSTALL_CMD"

success "Installation configuration complete!"
info "=========================================="
info "Next steps:"
info "  1. Edit hosts/$HOSTNAME/hardware-configuration.nix"
info "     - Confirm disk UUIDs and mount points are correct"
info "     - If using encryption, ensure luks config is correct"
info "  2. Run: nixos-install --flake .#$HOSTNAME"
info "  3. Reboot system: reboot"
info "=========================================="
