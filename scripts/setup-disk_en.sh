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
    echo "Notes:"
    echo "  If -T/-W/-S are omitted, an interactive terminal will prompt for them (Enter = default)."
    echo "  With -y or non-TTY stdin, the defaults desktop/hyprland/dms are used."
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

# Validate that an explicitly provided value is in the allowed list
# Usage: validate_choice <name> <value> <allowed...>
validate_choice() {
    local name="$1" value="$2"
    shift 2
    local allowed
    for allowed in "$@"; do
        [ "$value" = "$allowed" ] && return 0
    done
    error "$name has an invalid value: $value (allowed: $*)"
}

# Interactive selection: only prompts on an interactive terminal and outside -y mode;
# the chosen value is printed to stdout
# Usage: prompt_choice <prompt> <default> <options...>
prompt_choice() {
    local prompt="$1" default="$2" choice opt i
    shift 2
    local options=("$@")

    # Non-interactive mode or non-TTY stdin: fall back to the default so automation never stalls
    if [ "$NON_INTERACTIVE" = true ] || [ ! -t 0 ]; then
        warn "Not specified, using default: $default" >&2
        echo "$default"
        return 0
    fi

    while true; do
        echo -e "${YELLOW}${prompt}${NC}" >&2
        i=1
        for opt in "${options[@]}"; do
            if [ "$opt" = "$default" ]; then
                echo "  $i) $opt (default)" >&2
            else
                echo "  $i) $opt" >&2
            fi
            i=$((i + 1))
        done
        printf "Select [1-%d, press Enter to use default %s]: " "${#options[@]}" "$default" >&2
        read -r choice || choice=""

        # Empty input: use the default
        if [ -z "$choice" ]; then
            echo "$default"
            return 0
        fi
        # Numeric index
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            echo "${options[$((choice - 1))]}"
            return 0
        fi
        # Literal name
        for opt in "${options[@]}"; do
            if [ "$choice" = "$opt" ]; then
                echo "$opt"
                return 0
            fi
        done
        warn "Invalid choice: $choice, please try again" >&2
    done
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

# Validate explicitly provided values so invalid ones are not silently forwarded to install.sh
if [ -n "$HOST_TYPE" ]; then
    validate_choice "Host type" "$HOST_TYPE" desktop laptop server
fi
if [ -n "$WINDOW_MANAGER" ]; then
    validate_choice "Window manager" "$WINDOW_MANAGER" hyprland niri
fi
if [ -n "$DESKTOP_SHELL" ]; then
    validate_choice "Desktop shell" "$DESKTOP_SHELL" dms noctalia
fi

# When not explicitly specified: let the user choose on an interactive terminal;
# with -y or non-TTY stdin fall back to the recommended defaults so the flow never stalls
# (install.sh runs non-interactively and will not prompt again)
if [ -z "$HOST_TYPE" ]; then
    HOST_TYPE="$(prompt_choice "Select host type" desktop desktop laptop server)"
fi
if [ "$HOST_TYPE" != "server" ]; then
    if [ -z "$WINDOW_MANAGER" ]; then
        WINDOW_MANAGER="$(prompt_choice "Select window manager" hyprland hyprland niri)"
    fi
    if [ -z "$DESKTOP_SHELL" ]; then
        DESKTOP_SHELL="$(prompt_choice "Select desktop shell" dms dms noctalia)"
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

# Create the data partition (a LUKS container with encryption, otherwise a plain LVM PV)
info "Creating data partition..."
parted -s "$DISK" -- mkpart primary 512MiB 100%

# Notify the kernel to reload the partition table
partprobe "$DISK" 2>/dev/null || true
udevadm settle

EFI_PART="$(part_name "$DISK" 1)"
DATA_PART="$(part_name "$DISK" 2)"

info "EFI partition:  $EFI_PART"
info "Data partition: $DATA_PART"

[ -b "$EFI_PART" ] || error "EFI partition device did not appear: $EFI_PART"
[ -b "$DATA_PART" ] || error "Data partition device did not appear: $DATA_PART"

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
    printf '%s' "$CRYPT_PASSWORD" | cryptsetup luksFormat -q --type=luks2 --key-file=- "$DATA_PART"
    printf '%s' "$CRYPT_PASSWORD" | cryptsetup luksOpen --key-file=- "$DATA_PART" cryptroot
    unset CRYPT_PASSWORD CRYPT_PASSWORD_CONFIRM

    PV_DEV="/dev/mapper/cryptroot"
else
    info "Unencrypted mode: creating an LVM physical volume on the data partition"
    PV_DEV="$DATA_PART"
fi

# Both modes use LVM: / and swap are logical volumes; /home lives under / with no separate partition
info "Creating LVM physical volume and volume group..."
pvcreate -y "$PV_DEV"
vgcreate vg "$PV_DEV"

# Swap size scales with the disk: 10% of capacity, clamped to 2GiB-16GiB
PV_SIZE_BYTES="$(blockdev --getsize64 "$PV_DEV")"
SWAP_MB=$(( PV_SIZE_BYTES / 1024 / 1024 / 10 ))
if [ "$SWAP_MB" -gt 16384 ]; then
    SWAP_MB=16384
fi
if [ "$SWAP_MB" -lt 2048 ]; then
    SWAP_MB=2048
fi

info "Creating logical volumes (swap ${SWAP_MB}MiB / root fills the remainder)..."
lvcreate -y -L "${SWAP_MB}M" vg -n swap
lvcreate -y -l 100%FREE vg -n root

ROOT_DEV="/dev/vg/root"
SWAP_DEV="/dev/vg/swap"

for dev in "$ROOT_DEV" "$SWAP_DEV"; do
    [ -b "$dev" ] || error "Logical volume did not appear: $dev"
done

# Format filesystems (each device formatted exactly once)
info "Formatting filesystems..."
mkfs.ext4 -F -L nixos "$ROOT_DEV"
mkswap -L swap "$SWAP_DEV"

# Mount partitions
info "Mounting partitions..."
mount "$ROOT_DEV" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot

# Swap lives on the LVM logical volume
swapon "$SWAP_DEV"

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
info "Repository location: /mnt/etc/nixos (auto-cloned and host-config generated by the script)"
info "=========================================="
info "Next steps (run from /mnt/etc/nixos):"
info "  1. Review hosts/$TARGET_HOSTNAME/hardware-configuration.nix"
info "     - Confirm disk UUIDs and mount points are correct"
info "     - If using encryption, ensure luks config is correct"
info "  2. Install the system:"
info "       cd /mnt/etc/nixos"
info "       sudo nixos-install --flake .#$TARGET_HOSTNAME"
info "  3. Reboot system: reboot"
info "=========================================="
