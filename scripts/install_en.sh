#!/bin/sh
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
            USERNAME="$2"
            shift 2
            ;;
        -H|--hostname)
            HOSTNAME="$2"
            shift 2
            ;;
        -G|--git-user)
            GIT_USERNAME="$2"
            shift 2
            ;;
        -E|--git-email)
            GIT_EMAIL="$2"
            shift 2
            ;;
        -T|--host-type)
            HOST_TYPE_NAME="$2"
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
        -P|--polkit-agent)
            POLKIT_AGENT="$2"
            shift 2
            ;;
        -N|--name)
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

# Interactive input (if not provided via arguments)
info "Please enter the following configuration:"
echo

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
    info "Intel integrated GPU detected"
    GPU_KERNEL_PARAMS='
  boot.kernelParams = [
    "i915.enable_psr=0"
  ];'
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
sed -i.bak "s/USERNAME = \"youruser\"/USERNAME = \"$USERNAME\"/g" flake.nix
rm -f flake.nix.bak

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
fi

# Import host-type specific user-level configuration
echo "    ./$HOST_TYPE_NAME/default.nix" >> "home/hosts/$HOSTNAME.nix"

echo "  ];" >> "home/hosts/$HOSTNAME.nix"
echo "}" >> "home/hosts/$HOSTNAME.nix"

# =============================================
# Update user-related configurations
# =============================================
info "Updating Git configuration..."
sed -i.bak "s/Your Name/$GIT_USERNAME/g" home/common/git.nix
sed -i.bak "s/your.email@example.com/$GIT_EMAIL/g" home/common/git.nix
rm -f home/common/git.nix.bak

info "Updating hosts/common/default.nix user configuration..."
sed -i.bak "s/youruser/$USERNAME/g" hosts/common/default.nix
rm -f hosts/common/default.nix.bak

info "Updating modules/services/virtualisation.nix..."
sed -i.bak "s/youruser/$USERNAME/g" modules/services/virtualisation.nix
rm -f modules/services/virtualisation.nix.bak

# =============================================
# Configure flake.nix host output
# =============================================
info "Configuring flake.nix to add new host..."

# Check if host configuration already exists
if grep -q "    $FLAKE_NAME = mkHost" flake.nix; then
    warn "Host $FLAKE_NAME already exists in flake.nix"
    if confirm "Update existing configuration?"; then
        # Remove old config and re-add
        sed -i.bak "/    $FLAKE_NAME = mkHost/d" flake.nix
        sed -i.bak "/nixosConfigurations = {/a \\      $FLAKE_NAME = mkHost \"$HOSTNAME\";\\\n" flake.nix
        rm -f flake.nix.bak
    fi
else
    # Add new host configuration
    sed -i.bak "/nixosConfigurations = {/a \\      $FLAKE_NAME = mkHost \"$HOSTNAME\";\\\n" flake.nix
    rm -f flake.nix.bak
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
        if sudo nixos-generate-config --show-hardware-config > "hosts/$HOSTNAME/hardware-configuration.nix"; then
            info "Hardware configuration generated: hosts/$HOSTNAME/hardware-configuration.nix"
            info "Recommended: Check and edit hardware configuration file to ensure disk UUIDs and mount points are correct"
        else
            error "Failed to generate hardware configuration, please run manually:"
            error "  sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
        fi
    else
        error "nixos-generate-config command not available (may not be in NixOS installer)"
        info "Please run the following in NixOS installer:"
        info "  sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
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
echo "  nix build .#$FLAKE_NAME"
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
