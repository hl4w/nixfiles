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
set -euo pipefail

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

# Derive partition name: nvme/mmcblk/loop devices need "p1", sda/vda use "1"
part_name() {
    local disk="$1" index="$2"
    case "$disk" in
        /dev/nvme*|/dev/mmcblk*|/dev/loop*) echo "${disk}p${index}" ;;
        *) echo "${disk}${index}" ;;
    esac
}

# Defaults
NON_INTERACTIVE=false
USE_ENCRYPTION=true
REPO_URL="https://gitee.com/hl4w/nixfiles.git"
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
            [ -n "${2:-}" ] || error "Option $1 requires an argument"
            REPO_URL="$2"
            shift 2
            ;;
        -T|--host-type)
            [ -n "${2:-}" ] || error "Option $1 requires an argument"
            HOST_TYPE="$2"
            shift 2
            ;;
        -W|--wm)
            [ -n "${2:-}" ] || error "Option $1 requires an argument"
            WINDOW_MANAGER="$2"
            shift 2
            ;;
        -S|--shell)
            [ -n "${2:-}" ] || error "Option $1 requires an argument"
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
    echo "Error: missing required arguments" >&2
    echo >&2
    usage
fi

DISK="$1"
TARGET_HOSTNAME="$2"
TARGET_USERNAME="$3"

# Pre-flight checks: root privileges, device exists and is a block device
if [ "$(id -u)" != "0" ]; then
    error "This script must be run as root"
fi

[ -e "$DISK" ] || error "Disk device does not exist: $DISK"
[ -b "$DISK" ] || error "Path is not a block device: $DISK"

# install.sh runs non-interactively and will not prompt again;
# apply recommended defaults for unspecified desktop components so the flow never stalls
if [ -z "$HOST_TYPE" ]; then
    HOST_TYPE="desktop"
    warn "Host type not specified, using default: desktop"
fi
if [ "$HOST_TYPE" != "server" ]; then
    if [ -z "$WINDOW_MANAGER" ]; then
        WINDOW_MANAGER="hyprland"
        warn "Window manager not specified, using default: hyprland"
    fi
    if [ -z "$DESKTOP_SHELL" ]; then
        DESKTOP_SHELL="dms"
        warn "Desktop shell not specified, using default: dms"
    fi
fi

# Show configuration summary
info "=========================================="
info "      HL4W NixOS Disk Setup Utility"
info "=========================================="
echo
info "Configuration parameters:"
info "  Disk device:      $DISK"
info "  Hostname:         $TARGET_HOSTNAME"
info "  Username:         $TARGET_USERNAME"
info "  Encryption:       $(if [ "$USE_ENCRYPTION" = true ]; then echo "enabled"; else echo "disabled"; fi)"
info "  Repository URL:   $REPO_URL"
if [ -n "$HOST_TYPE" ]; then
    info "  Host type:        $HOST_TYPE"
fi
if [ -n "$WINDOW_MANAGER" ]; then
    info "  Window manager:   $WINDOW_MANAGER"
fi
if [ -n "$DESKTOP_SHELL" ]; then
    info "  Desktop shell:    $DESKTOP_SHELL"
fi
echo

# Confirm operation
if ! confirm "This operation will erase ALL DATA on $DISK! Continue?"; then
    info "Operation cancelled"
    exit 0
fi

# Unmount possibly mounted partitions
info "Unmounting mounted partitions..."
swapoff -a 2>/dev/null || true
umount -R /mnt 2>/dev/null || true
vgchange -an vg 2>/dev/null || true
cryptsetup luksClose cryptroot 2>/dev/null || true

# Create partition table
info "Creating GPT partition table..."
parted -s "$DISK" -- mklabel gpt

# Create EFI partition (512MiB)
info "Creating EFI partition..."
parted -s "$DISK" -- mkpart ESP fat32 1MiB 512MiB
parted -s "$DISK" -- set 1 esp on

# Create root partition (with encryption the whole disk is a LUKS container;
# without encryption split the remaining space between / and home)
if [ "$USE_ENCRYPTION" = true ]; then
    info "Creating LUKS partition..."
    parted -s "$DISK" -- mkpart primary 512MiB 100%
else
    info "Creating root and home partitions..."
    parted -s "$DISK" -- mkpart primary ext4 512MiB 60%
    parted -s "$DISK" -- mkpart primary ext4 60% 100%
fi

# Notify the kernel to reload the partition table
partprobe "$DISK" 2>/dev/null || true
udevadm settle

EFI_PART="$(part_name "$DISK" 1)"
ROOT_PART="$(part_name "$DISK" 2)"

info "EFI partition:  $EFI_PART"
info "Root partition: $ROOT_PART"

[ -b "$EFI_PART" ] || error "EFI partition device did not appear: $EFI_PART"
[ -b "$ROOT_PART" ] || error "Root partition device did not appear: $ROOT_PART"

# Format EFI partition
info "Formatting EFI partition..."
mkfs.fat -F 32 -n BOOT "$EFI_PART"

if [ "$USE_ENCRYPTION" = true ]; then
    # Ask for the passphrase twice to avoid an unbootable system
    read -rsp "Enter encryption password: " CRYPT_PASSWORD
    echo
    read -rsp "Confirm encryption password: " CRYPT_PASSWORD_CONFIRM
    echo

    if [ "$CRYPT_PASSWORD" != "$CRYPT_PASSWORD_CONFIRM" ]; then
        error "Passwords do not match"
    fi
    [ -n "$CRYPT_PASSWORD" ] || error "Encryption password must not be empty"

    info "Creating encrypted partition..."
    printf '%s' "$CRYPT_PASSWORD" | cryptsetup luksFormat -q --type=luks2 --key-file=- "$ROOT_PART"
    printf '%s' "$CRYPT_PASSWORD" | cryptsetup luksOpen --key-file=- "$ROOT_PART" cryptroot
    unset CRYPT_PASSWORD CRYPT_PASSWORD_CONFIRM

    # Create LVM volume group
    info "Creating LVM volume group..."
    pvcreate /dev/mapper/cryptroot
    vgcreate vg /dev/mapper/cryptroot

    info "Creating logical volumes (root 60% / swap / home remainder)..."
    lvcreate -l 60%FREE vg -n root
    lvcreate -L 16G vg -n swap
    lvcreate -l 100%FREE vg -n home

    ROOT_DEV="/dev/vg/root"
    HOME_DEV="/dev/vg/home"
    SWAP_DEV="/dev/vg/swap"
else
    # Unencrypted: p2 is /, p3 is home
    ROOT_DEV="$ROOT_PART"
    HOME_DEV="$(part_name "$DISK" 3)"
    [ -b "$HOME_DEV" ] || error "Home partition device did not appear: $HOME_DEV"
    SWAP_DEV=""
fi

# Format filesystems (each device formatted exactly once)
info "Formatting filesystems..."
mkfs.ext4 -F -L nixos "$ROOT_DEV"
mkfs.ext4 -F -L home "$HOME_DEV"

if [ "$USE_ENCRYPTION" = true ]; then
    mkswap -L swap "$SWAP_DEV"
fi

# Mount partitions
info "Mounting partitions..."
mount "$ROOT_DEV" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot
mkdir -p /mnt/home
mount "$HOME_DEV" /mnt/home

# Swap: use the LV when encrypted; otherwise create a swapfile after mounting /
if [ "$USE_ENCRYPTION" = true ]; then
    swapon "$SWAP_DEV"
else
    info "Creating swap file..."
    fallocate -l 16G /mnt/swapfile
    chmod 600 /mnt/swapfile
    mkswap /mnt/swapfile
    swapon /mnt/swapfile
fi

success "Partition and mount complete!"

# Install git (the installer media usually ships it already)
if ! command -v git &> /dev/null; then
    info "Installing git..."
    nix-env -iA nixos.git -q
fi

# Clone config repository
info "Cloning config repository..."
mkdir -p /mnt/etc/nixos
cd /mnt/etc/nixos
if [ -d .git ]; then
    info "Existing repository detected, running git pull..."
    git pull --ff-only
else
    git clone "$REPO_URL" .
fi

# Run install script (array arguments, no eval injection risk)
info "Running install script..."
chmod +x scripts/install.sh

INSTALL_ARGS=(-y -H "$TARGET_HOSTNAME" -U "$TARGET_USERNAME")
if [ -n "$HOST_TYPE" ]; then
    INSTALL_ARGS+=(-T "$HOST_TYPE")
fi
if [ -n "$WINDOW_MANAGER" ]; then
    INSTALL_ARGS+=(-W "$WINDOW_MANAGER")
fi
if [ -n "$DESKTOP_SHELL" ]; then
    INSTALL_ARGS+=(-S "$DESKTOP_SHELL")
fi

./scripts/install.sh "${INSTALL_ARGS[@]}"

success "Installation configuration complete!"
info "=========================================="
info "Next steps:"
info "  1. Review hosts/$TARGET_HOSTNAME/hardware-configuration.nix"
info "     - Confirm disk UUIDs and mount points are correct"
info "     - If using encryption, ensure luks config is correct"
info "  2. Run: nixos-install --flake .#$TARGET_HOSTNAME"
info "  3. Reboot system: reboot"
info "=========================================="
