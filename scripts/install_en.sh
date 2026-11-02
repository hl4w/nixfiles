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

# Escape sed replacement special characters (/ & \)
# Prevents sed substitution breakage when username/email/hostname contain metacharacters
sed_escape_replacement() {
    printf '%s' "$1" | sed -e 's/[\\&/]/\\&/g'
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
    echo "  -U, --username      Specify username"
    echo "  -H, --hostname      Specify hostname"
    echo "  -G, --git-user      Specify Git username"
    echo "  -E, --git-email     Specify Git email"
    echo "  -T, --host-type     Specify host type: desktop/laptop/server"
    echo "  -W, --wm            Specify window manager: hyprland/niri (desktop/laptop only)"
    echo "  -S, --shell         Specify desktop shell: dms/noctalia (desktop/laptop only)"
    echo "  -P, --polkit-agent  Specify polkit agent: kde/hyprland (desktop/laptop only, default kde)"
    echo "  -N, --name          Specify flake configuration name (default: hostname)"
    echo
    echo "Examples:"
    echo "  $0 -y -U john -H my-desktop -N my-desktop-config -T desktop -W hyprland -S dms -P kde"
    exit 0
}

# Defaults
USERNAME=""
HOSTNAME=""
FLAKE_NAME=""
GIT_USERNAME=""
GIT_EMAIL=""
HOST_TYPE_NAME=""
WINDOW_MANAGER=""
DESKTOP_SHELL=""
POLKIT_AGENT=""
NON_INTERACTIVE="false"
# Laptop power management flag, defaults to false so it is never uninitialized
POWER_MANAGEMENT="false"

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
        -U|--username)
            [ -n "${2:-}" ] || error "Option $1 requires a username argument"
            USERNAME="$2"
            shift 2
            ;;
        -H|--hostname)
            [ -n "${2:-}" ] || error "Option $1 requires a hostname argument"
            HOSTNAME="$2"
            shift 2
            ;;
        -G|--git-user)
            [ -n "${2:-}" ] || error "Option $1 requires a Git username argument"
            GIT_USERNAME="$2"
            shift 2
            ;;
        -E|--git-email)
            [ -n "${2:-}" ] || error "Option $1 requires a Git email argument"
            GIT_EMAIL="$2"
            shift 2
            ;;
        -T|--host-type)
            [ -n "${2:-}" ] || error "Option $1 requires a host type argument"
            HOST_TYPE_NAME="$2"
            shift 2
            ;;
        -W|--wm)
            [ -n "${2:-}" ] || error "Option $1 requires a window manager argument"
            WINDOW_MANAGER="$2"
            shift 2
            ;;
        -S|--shell)
            [ -n "${2:-}" ] || error "Option $1 requires a desktop shell argument"
            DESKTOP_SHELL="$2"
            shift 2
            ;;
        -P|--polkit-agent)
            [ -n "${2:-}" ] || error "Option $1 requires a polkit agent argument"
            POLKIT_AGENT="$2"
            shift 2
            ;;
        -N|--name)
            [ -n "${2:-}" ] || error "Option $1 requires a flake configuration name argument"
            FLAKE_NAME="$2"
            shift 2
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

info "=========================================="
info "       HL4W NixOS Configuration Installer"
info "=========================================="
echo

# Non-interactive mode: fail fast on missing required arguments instead of blocking on prompts
if [ "$NON_INTERACTIVE" = "true" ]; then
    [ -n "$USERNAME" ] || error "Non-interactive mode requires -U/--username"
    [ -n "$HOSTNAME" ] || error "Non-interactive mode requires -H/--hostname"
    [ -n "$HOST_TYPE_NAME" ] || error "Non-interactive mode requires -T/--host-type"
    [ -n "$FLAKE_NAME" ] || FLAKE_NAME="$HOSTNAME"
    [ -n "$GIT_USERNAME" ] || GIT_USERNAME="$USERNAME"
    [ -n "$GIT_EMAIL" ] || GIT_EMAIL="$USERNAME@example.com"
    if [ "$HOST_TYPE_NAME" != "server" ]; then
        [ -n "$WINDOW_MANAGER" ] || error "Non-interactive mode requires -W/--wm"
        [ -n "$DESKTOP_SHELL" ] || error "Non-interactive mode requires -S/--shell"
        [ -n "$POLKIT_AGENT" ] || POLKIT_AGENT="kde"
    fi
else
    # Interactive input (if not provided via arguments)
    info "Please enter the following configuration:"
    echo
fi

if [ -z "$USERNAME" ]; then
    read -p "Username: " -e USERNAME
    if [ -z "$USERNAME" ]; then
        error "Username cannot be empty"
    fi
fi

if [ -z "$HOSTNAME" ]; then
    read -p "Hostname: " -e HOSTNAME
    if [ -z "$HOSTNAME" ]; then
        error "Hostname cannot be empty"
    fi
fi

if [ -z "$FLAKE_NAME" ]; then
    read -p "Flake configuration name (default: hostname): " -e FLAKE_NAME
    if [ -z "$FLAKE_NAME" ]; then
        FLAKE_NAME="$HOSTNAME"
        info "Using hostname as flake configuration name: $FLAKE_NAME"
    fi
fi

if [ -z "$GIT_USERNAME" ]; then
    read -p "Git username: " -e GIT_USERNAME
    if [ -z "$GIT_USERNAME" ]; then
        warn "Git username is empty, will use default value"
        GIT_USERNAME="$USERNAME"
    fi
fi

if [ -z "$GIT_EMAIL" ]; then
    read -p "Git email: " -e GIT_EMAIL
    if [ -z "$GIT_EMAIL" ]; then
        warn "Git email is empty, will use default value"
        GIT_EMAIL="$USERNAME@example.com"
    fi
fi

if [ -z "$HOST_TYPE_NAME" ]; then
    echo
    info "Select host type:"
    echo "  1) Desktop (high-performance hardware)"
    echo "  2) Laptop (battery management, touchpad)"
    echo "  3) Server (no desktop environment)"
    read -p "Enter choice (1/2/3): " -e HOST_TYPE
    case $HOST_TYPE in
        1)
            HOST_TYPE_NAME="desktop"
            ;;
        2)
            HOST_TYPE_NAME="laptop"
            ;;
        3)
            HOST_TYPE_NAME="server"
            ;;
        *)
            error "Invalid selection"
            ;;
    esac
fi

if [ "$HOST_TYPE_NAME" != "server" ]; then
    if [ -z "$WINDOW_MANAGER" ]; then
        echo
        info "Select window manager:"
        echo "  1) Hyprland (dynamic tiling, recommended)"
        echo "  2) Niri (modern tiling, good for laptops)"
        read -p "Enter choice (1/2): " -e WM_CHOICE
        case $WM_CHOICE in
            1)
                WINDOW_MANAGER="hyprland"
                ;;
            2)
                WINDOW_MANAGER="niri"
                ;;
            *)
                error "Invalid selection"
                ;;
        esac
    fi

    if [ -z "$DESKTOP_SHELL" ]; then
        echo
        info "Select desktop shell:"
        echo "  1) DMS-Shell (lightweight display manager shell)"
        echo "  2) Noctalia-Shell (modern desktop integration shell)"
        read -p "Enter choice (1/2): " -e SHELL_CHOICE
        case $SHELL_CHOICE in
            1)
                DESKTOP_SHELL="dms"
                ;;
            2)
                DESKTOP_SHELL="noctalia"
                ;;
            *)
                error "Invalid selection"
                ;;
        esac
    fi

    if [ -z "$POLKIT_AGENT" ]; then
        echo
        info "Select polkit agent:"
        echo "  1) KDE (polkit-kde-agent-1, full-featured, recommended)"
        echo "  2) Hyprland (hyprpolkitagent, lightweight)"
        read -p "Enter choice (1/2, default 1): " -e POLKIT_CHOICE
        case $POLKIT_CHOICE in
            2)
                POLKIT_AGENT="hyprland"
                ;;
            *)
                POLKIT_AGENT="kde"
                ;;
        esac
    fi
fi

# Validate every value regardless of interactive or argument input
case "$HOST_TYPE_NAME" in
    desktop|laptop|server) ;;
    *) error "Invalid host type: $HOST_TYPE_NAME (expected: desktop/laptop/server)" ;;
esac

if [ "$HOST_TYPE_NAME" != "server" ]; then
    case "$WINDOW_MANAGER" in
        hyprland|niri) ;;
        *) error "Invalid window manager: $WINDOW_MANAGER (expected: hyprland/niri)" ;;
    esac
    case "$DESKTOP_SHELL" in
        dms|noctalia) ;;
        *) error "Invalid desktop shell: $DESKTOP_SHELL (expected: dms/noctalia)" ;;
    esac
    case "$POLKIT_AGENT" in
        kde|hyprland) ;;
        *) error "Invalid polkit agent: $POLKIT_AGENT (expected: kde/hyprland)" ;;
    esac
fi

echo
info "Configuration Summary:"
echo "------------------------------------------"
echo "Username:        $USERNAME"
echo "Hostname:        $HOSTNAME"
echo "Flake name:      $FLAKE_NAME"
echo "Host type:       $HOST_TYPE_NAME"
echo "Window manager:  ${WINDOW_MANAGER:-none}"
echo "Desktop shell:   ${DESKTOP_SHELL:-none}"
echo "Polkit agent:    ${POLKIT_AGENT:-none}"
echo "Git username:    $GIT_USERNAME"
echo "Git email:       $GIT_EMAIL"
echo "------------------------------------------"

if ! confirm "Confirm that the above configuration is correct?"; then
    error "Installation cancelled by user"
fi

echo
info "Starting project configuration..."

# =============================================
# GPU Hardware Detection
# =============================================
info "Detecting GPU hardware..."

GPU_TYPE=""
GPU_KERNEL_PARAMS=""
GPU_IMPORTS=""

# Detect NVIDIA GPU
if lspci 2>/dev/null | grep -qi "nvidia"; then
    GPU_TYPE="nvidia"
    info "NVIDIA GPU detected"
    GPU_IMPORTS="    ../../modules/hardware/nvidia.nix"
    GPU_KERNEL_PARAMS='
  # NVIDIA GPU configuration
  boot.kernelParams = [
    "nvidia_drm.modeset=1"
    "nvidia_drm.fbdev=1"
  ];'
# Detect AMD GPU
elif lspci 2>/dev/null | grep -qiE "(vga|3d).*amd|ati|radeon"; then
    GPU_TYPE="amd"
    info "AMD/ATI GPU detected"
    GPU_KERNEL_PARAMS='
  boot.kernelParams = [
    "amdgpu.si_support=1"
    "amdgpu.cik_support=1"
  ];'
# Detect Intel integrated GPU
elif lspci 2>/dev/null | grep -qiE "(vga|3d).*intel"; then
    GPU_TYPE="intel"
    info "Intel integrated GPU detected (using kernel default driver parameters)"
else
    GPU_TYPE="unknown"
    info "Unknown GPU type, using generic configuration"
fi

echo "  GPU Type:      ${GPU_TYPE}"
echo "------------------------------------------"

# =============================================
# Configure flake.nix
# =============================================
info "Configuring flake.nix..."
info "Updating username..."
USERNAME_ESC=$(sed_escape_replacement "$USERNAME")
if grep -q 'USERNAME = "youruser"' flake.nix; then
    sed -i.bak "s/USERNAME = \"youruser\"/USERNAME = \"$USERNAME_ESC\"/g" flake.nix
    rm -f flake.nix.bak
    info "flake.nix username updated: $USERNAME"
else
    warn "Placeholder 'youruser' not found in flake.nix, likely already replaced. Skipping username update."
fi

# =============================================
# Create host configuration directory
# =============================================
info "Checking if host already exists..."
if [ -d "hosts/$HOSTNAME" ]; then
    warn "Host $HOSTNAME already exists, will update configuration"
    if confirm "Overwrite existing configuration?"; then
        info "Backing up existing configuration..."
        mv "hosts/$HOSTNAME" "hosts/${HOSTNAME}_backup_$(date +%Y%m%d_%H%M%S)"
    else
        error "User cancelled overwrite"
    fi
fi

info "Creating host configuration directory..."
mkdir -p "hosts/$HOSTNAME"

# =============================================
# Generate host configuration.nix
# =============================================
info "Generating host configuration.nix..."
cat > "hosts/$HOSTNAME/configuration.nix" << EOF
{ pkgs, ... }:

{
  imports = [
    ../common/default.nix
    ./hardware-configuration.nix
EOF

case $HOST_TYPE_NAME in
    desktop)
        echo "    ../../modules/desktops/desktop.nix" >> "hosts/$HOSTNAME/configuration.nix"
        ;;
    laptop)
        echo "    ../../modules/desktops/desktop.nix" >> "hosts/$HOSTNAME/configuration.nix"
        echo "    ../../modules/hardware/bluetooth.nix" >> "hosts/$HOSTNAME/configuration.nix"
        POWER_MANAGEMENT=true
        ;;
    server)
        ;;
esac

# Add NVIDIA module import
if [ "$GPU_TYPE" = "nvidia" ]; then
    echo "$GPU_IMPORTS" >> "hosts/$HOSTNAME/configuration.nix"
fi

cat >> "hosts/$HOSTNAME/configuration.nix" << EOF
  ];

  networking.hostName = "$HOSTNAME";
EOF

# Add GPU kernel parameters
if [ -n "$GPU_KERNEL_PARAMS" ]; then
    echo "$GPU_KERNEL_PARAMS" >> "hosts/$HOSTNAME/configuration.nix"
fi

# Add desktop config options (desktop/laptop only)
if [ "$HOST_TYPE_NAME" != "server" ]; then
    cat >> "hosts/$HOSTNAME/configuration.nix" << EOF

  # Desktop configuration
  desktop = {
    windowManager = "$WINDOW_MANAGER";
    shell = "$DESKTOP_SHELL";
    enableInputMethod = true;
    polkitAgent = "${POLKIT_AGENT:-kde}";
  };
EOF
fi

if [ "$POWER_MANAGEMENT" = true ]; then
    cat >> "hosts/$HOSTNAME/configuration.nix" << EOF

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };
EOF
fi

if [ "$HOST_TYPE_NAME" = "server" ]; then
    cat >> "hosts/$HOSTNAME/configuration.nix" << EOF

  services.openssh.enable = true;
EOF
fi

echo "}" >> "hosts/$HOSTNAME/configuration.nix"

# =============================================
# Create user Home Manager configuration
# =============================================
info "Creating user Home Manager configuration..."
mkdir -p "home/hosts"

# Check if host user config already exists
if [ -f "home/hosts/$HOSTNAME.nix" ]; then
    warn "User configuration $HOSTNAME.nix already exists, will update"
fi

cat > "home/hosts/$HOSTNAME.nix" << EOF
{ pkgs, config, inputs, ... }:

{
  imports = [
    ../common/default.nix
EOF

if [ "$HOST_TYPE_NAME" != "server" ]; then
    echo "    ../common/input.nix" >> "home/hosts/$HOSTNAME.nix"
    echo "    ../common/apps.nix" >> "home/hosts/$HOSTNAME.nix"
    # Import user-level theme (GTK/XDG icons/WM colors)
    echo "    ../common/unified-theme.nix" >> "home/hosts/$HOSTNAME.nix"
    # Import WM-specific configuration based on selection
    case $WINDOW_MANAGER in
        hyprland)
            echo "    ../common/hyprland.nix" >> "home/hosts/$HOSTNAME.nix"
            ;;
        niri)
            echo "    ../common/niri.nix" >> "home/hosts/$HOSTNAME.nix"
            ;;
    esac
fi

# Import host-type specific user-level configuration
echo "    ./$HOST_TYPE_NAME/default.nix" >> "home/hosts/$HOSTNAME.nix"

echo "  ];" >> "home/hosts/$HOSTNAME.nix"
echo "}" >> "home/hosts/$HOSTNAME.nix"

# =============================================
# Update user-related configurations
# =============================================

info "Updating Git configuration..."

GIT_USERNAME_ESC=$(sed_escape_replacement "$GIT_USERNAME")
GIT_EMAIL_ESC=$(sed_escape_replacement "$GIT_EMAIL")

# Check and replace the Git username placeholder in git.nix
# Uses a precise pattern (with field name userName) to avoid mismatches and support idempotent runs
if grep -q 'userName = "Your Name"' home/common/git.nix; then
    sed -i.bak "s/userName = \"Your Name\"/userName = \"$GIT_USERNAME_ESC\"/" home/common/git.nix
    rm -f home/common/git.nix.bak
    info "Git username updated: $GIT_USERNAME"
else
    warn "Placeholder 'Your Name' not found in git.nix, likely already replaced. Skipping username update."
    warn "To change the Git username, manually edit the userName field in home/common/git.nix"
fi

# Check and replace the Git email placeholder in git.nix
if grep -q 'userEmail = "your.email@example.com"' home/common/git.nix; then
    sed -i.bak "s/userEmail = \"your.email@example.com\"/userEmail = \"$GIT_EMAIL_ESC\"/" home/common/git.nix
    rm -f home/common/git.nix.bak
    info "Git email updated: $GIT_EMAIL"
else
    warn "Placeholder 'your.email@example.com' not found in git.nix, likely already replaced. Skipping email update."
    warn "To change the Git email, manually edit the userEmail field in home/common/git.nix"
fi

info "Updating user-related placeholders..."

# The username may contain sed metacharacters, so it must be escaped before substitution
for target in hosts/common/default.nix modules/services/virtualisation.nix; do
    if [ ! -f "$target" ]; then
        warn "File does not exist, skipping: $target"
        continue
    fi
    if grep -q 'youruser' "$target"; then
        sed -i.bak "s/youruser/${USERNAME_ESC}/g" "$target"
        rm -f "${target}.bak"
        # Verify after substitution to avoid silent failures
        if grep -q 'youruser' "$target"; then
            error "Failed to replace username placeholder: $target"
        fi
        info "Username placeholder updated: $target"
    else
        info "No 'youruser' placeholder found, skipping: $target"
    fi
done

# =============================================
# Configure flake.nix host output
# =============================================
info "Configuring flake.nix to add new host..."

# FLAKE_NAME must be quoted as a nix attribute name
# Otherwise names with hyphens (e.g. my-desktop) are parsed as subtraction, causing a syntax error
FLAKE_ENTRY="      \"${FLAKE_NAME}\" = mkHost \"${HOSTNAME}\";"

# Check if host configuration already exists (match the quoted attribute name exactly)
if grep -qF "\"${FLAKE_NAME}\" = mkHost" flake.nix; then
    warn "Host $FLAKE_NAME already exists in flake.nix"
    if confirm "Update existing configuration?"; then
        # Remove the old config line
        sed -i.bak "/\"${FLAKE_NAME}\" = mkHost/d" flake.nix
        rm -f flake.nix.bak
        # Insert the new config line (using awk to avoid cross-version issues with sed 'a' command)
        awk -v entry="$FLAKE_ENTRY" 'index($0, "nixosConfigurations = {") {print; print entry; next} {print}' flake.nix > flake.nix.tmp && mv flake.nix.tmp flake.nix
        info "Host configuration updated: \"${FLAKE_NAME}\" = mkHost \"${HOSTNAME}\""
    else
        error "User cancelled configuration update"
    fi
else
    # Add new host configuration
    awk -v entry="$FLAKE_ENTRY" 'index($0, "nixosConfigurations = {") {print; print entry; next} {print}' flake.nix > flake.nix.tmp && mv flake.nix.tmp flake.nix
    info "Added host configuration: \"${FLAKE_NAME}\" = mkHost \"${HOSTNAME}\""
fi

# Verify the insertion succeeded
if grep -qF "\"${FLAKE_NAME}\" = mkHost" flake.nix; then
    info "flake.nix host configuration verified successfully"
else
    error "flake.nix host configuration insertion failed, please manually check the nixosConfigurations block in flake.nix"
fi

# =============================================
# Generate flake.lock
# =============================================
info "Generating flake.lock..."
nix flake lock

# =============================================
# Generate hardware configuration
# =============================================
echo
if confirm "Generate hardware configuration now? (requires sudo)"; then
    info "Generating hardware configuration..."
    if command -v nixos-generate-config &> /dev/null; then
        # In the installer the target root is mounted at /mnt,
        # so --root /mnt is required to detect the correct mount points and UUIDs
        GEN_ARGS=(--show-hardware-config)
        if [ -d /mnt/etc ] && mountpoint -q /mnt 2>/dev/null; then
            GEN_ARGS=(--root /mnt --show-hardware-config)
        fi

        if sudo nixos-generate-config "${GEN_ARGS[@]}" > "hosts/$HOSTNAME/hardware-configuration.nix"; then
            info "Hardware configuration generated: hosts/$HOSTNAME/hardware-configuration.nix"
            info "Recommended: Check and edit hardware configuration file to ensure disk UUIDs and mount points are correct"
        else
            error "Failed to generate hardware configuration, please run manually: sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
        fi
    else
        warn "nixos-generate-config command not available (may not be in NixOS installer)"
        info "Please run the following in NixOS installer:"
        info "  sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
        exit 1
    fi
else
    info "Skipping automatic hardware configuration generation"
    warn "⚠️ Hardware configuration file has not been created!"
    info "Please generate manually in NixOS installer:"
    info "  sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
fi

# =============================================
# Verify configuration
# =============================================
echo
if confirm "Verify configuration correctness?"; then
    info "Verifying flake configuration..."
    if nix flake check; then
        info "✅ Flake configuration verified successfully"
    else
        warn "❌ Flake configuration verification failed, please check error messages"
    fi
fi

# =============================================
# Completion message
# =============================================
echo
info "=========================================="
info "         Configuration Complete!"
info "=========================================="
echo
info "Project configured successfully. Use the following commands to update the system:"
echo "------------------------------------------"
echo ""
echo "📦 System Update Commands:"
echo "------------------------------------------"
echo "# Update system after modifying modules/:"
echo "  sudo nixos-rebuild switch --flake .#$FLAKE_NAME"
echo ""
echo "# Update user configuration after modifying home/:"
echo "  home-manager switch --flake .#$USERNAME@$FLAKE_NAME"
echo ""
echo "# Update flake inputs (upgrade nixpkgs, etc.):"
echo "  nix flake update"
echo ""
echo "# One-click update script (recommended):"
echo "  ./scripts/update.sh"
echo ""
echo "🔧 Verification Commands:"
echo "------------------------------------------"
echo "# Check configuration syntax:"
echo "  nix flake check"
echo ""
echo "# Test build (no deployment):"
echo "  nix build .#nixosConfigurations.\"$FLAKE_NAME\".config.system.build.toplevel"
echo ""
echo "# Rollback to previous generation:"
echo "  sudo nixos-rebuild switch --rollback"
echo ""
echo "📝 Next Steps:"
echo "------------------------------------------"
echo "1. Ensure hardware configuration is generated:"
echo "   hosts/$HOSTNAME/hardware-configuration.nix"
echo ""
echo "2. Edit hardware-configuration.nix and verify:"
echo "   - Ensure root partition device points to correct disk/partition"
echo "   - Check boot partition mount point"
echo "   - Verify swap configuration"
echo ""
echo "3. Deploy system in NixOS installer:"
echo "   sudo nixos-rebuild switch --flake .#$FLAKE_NAME"
echo ""
echo "4. Update Home Manager after deployment:"
echo "   home-manager switch --flake .#$USERNAME@$FLAKE_NAME"
echo "------------------------------------------"
echo
info "Note: After installation, you can modify files in modules/ or home/ directories,"
info "then run 'sudo nixos-rebuild switch --flake .#$FLAKE_NAME' to apply changes!"
