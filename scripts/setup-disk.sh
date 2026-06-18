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

# 颜色输出
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
    echo "用法: $0 [选项] <磁盘设备> <主机名> <用户名>"
    echo
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -y, --yes           非交互式模式，自动确认所有提示"
    echo "  -c, --no-crypto     不使用加密（WARNING: 不推荐）"
    echo "  -r, --repo-url      指定配置仓库 URL"
    echo "  -T, --host-type     指定主机类型: desktop/laptop/server"
    echo "  -W, --wm            指定窗口管理器: hyprland/niri"
    echo "  -S, --shell         指定桌面 Shell: dms/noctalia"
    echo
    echo "示例:"
    echo "  $0 -y /dev/nvme0n1 my-desktop john"
    echo "  $0 -y -T desktop -W hyprland -S dms /dev/nvme0n1 my-desktop john"
    exit 0
}

# 默认值
NON_INTERACTIVE=false
USE_ENCRYPTION=true
REPO_URL="https://gitee.com/hl4w/nixfiles.git"
HOST_TYPE=""
WINDOW_MANAGER=""
DESKTOP_SHELL=""

# 解析命令行参数
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
            warn "警告: 将不使用磁盘加密，这会降低系统安全性！"
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
            # 位置参数
            break
            ;;
    esac
done

# 检查位置参数
if [ $# -ne 3 ]; then
    error "缺少必需参数"
    usage
fi

DISK="$1"
HOSTNAME="$2"
USERNAME="$3"

# 显示配置摘要
info "=========================================="
info "      HL4W NixOS Disk Setup Utility"
info "=========================================="
echo
info "配置参数:"
info "  磁盘设备:      $DISK"
info "  主机名:        $HOSTNAME"
info "  用户名:        $USERNAME"
info "  加密:          $(if [ "$USE_ENCRYPTION" = true ]; then echo "启用"; else echo "禁用"; fi)"
info "  仓库 URL:      $REPO_URL"
if [ -n "$HOST_TYPE" ]; then
    info "  主机类型:      $HOST_TYPE"
fi
if [ -n "$WINDOW_MANAGER" ]; then
    info "  窗口管理器:    $WINDOW_MANAGER"
fi
if [ -n "$DESKTOP_SHELL" ]; then
    info "  桌面 Shell:    $DESKTOP_SHELL"
fi
echo

# 确认操作
if ! confirm "此操作将清除 $DISK 上的所有数据！继续?"; then
    info "操作已取消"
    exit 0
fi

# 检查是否为 root
if [ "$(id -u)" != "0" ]; then
    error "必须以 root 用户运行此脚本"
fi

# 卸载可能已挂载的分区
info "卸载已挂载的分区..."
umount /mnt/home 2>/dev/null || true
umount /mnt/boot 2>/dev/null || true
umount /mnt 2>/dev/null || true
swapoff /dev/mapper/vg-swap 2>/dev/null || true
cryptsetup luksClose cryptroot 2>/dev/null || true

# 创建分区表
info "创建 GPT 分区表..."
parted "$DISK" -- mklabel gpt

# 创建 EFI 分区 (511MB)
info "创建 EFI 分区..."
parted "$DISK" -- mkpart ESP fat32 1MiB 512MiB
parted "$DISK" -- set 1 esp on

# 创建根分区 (剩余空间)
info "创建根分区..."
parted "$DISK" -- mkpart primary 512MiB 100%

# 获取分区路径
EFI_PART="${DISK}p1"
ROOT_PART="${DISK}p2"

info "EFI 分区: $EFI_PART"
info "根分区: $ROOT_PART"

# 格式化 EFI 分区
info "格式化 EFI 分区..."
mkfs.fat -F 32 "$EFI_PART"

if [ "$USE_ENCRYPTION" = true ]; then
    # 创建加密分区
    info "创建加密分区..."
    echo -n "输入加密密码: "
    read -s CRYPT_PASSWORD
    echo
    echo ""

    echo "$CRYPT_PASSWORD" | cryptsetup luksFormat --type=luks2 "$ROOT_PART" -d -
    echo "$CRYPT_PASSWORD" | cryptsetup luksOpen "$ROOT_PART" cryptroot -d -

    # 创建 LVM 卷组
    info "创建 LVM 卷组..."
    pvcreate /dev/mapper/cryptroot
    vgcreate vg /dev/mapper/cryptroot

    ROOT_DEV="/dev/vg/root"
    HOME_DEV="/dev/vg/home"
    SWAP_DEV="/dev/vg/swap"
else
    # 不使用加密，直接格式化
    ROOT_DEV="$ROOT_PART"
    HOME_DEV="${DISK}p3"
    
    # 创建 home 分区
    info "创建 home 分区..."
    parted "$DISK" -- mkpart primary 80.5GiB 100%
    
    # 创建 swap 文件
    SWAP_DEV="/mnt/swapfile"
fi

# 创建逻辑卷或分区
if [ "$USE_ENCRYPTION" = true ]; then
    info "创建逻辑卷..."
    lvcreate -L 80G vg -n root
    lvcreate -L 16G vg -n swap
    lvcreate -l 100%FREE vg -n home
else
    info "格式化根分区..."
    mkfs.ext4 "$ROOT_DEV"
    
    info "格式化 home 分区..."
    mkfs.ext4 "$HOME_DEV"
fi

# 格式化文件系统
info "格式化文件系统..."
if [ "$USE_ENCRYPTION" = true ]; then
    mkfs.ext4 "$ROOT_DEV"
    mkfs.ext4 "$HOME_DEV"
    mkswap "$SWAP_DEV"
else
    mkswap "$SWAP_DEV"
fi

# 挂载分区
info "挂载分区..."
mount "$ROOT_DEV" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot
mkdir -p /mnt/home
mount "$HOME_DEV" /mnt/home

if [ "$USE_ENCRYPTION" = true ]; then
    swapon "$SWAP_DEV"
else
    # 创建 swap 文件
    info "创建 swap 文件..."
    fallocate -l 16G "$SWAP_DEV"
    chmod 600 "$SWAP_DEV"
    mkswap "$SWAP_DEV"
    swapon "$SWAP_DEV"
fi

success "分区和挂载完成！"

# 安装 git
info "安装 git..."
nix-env -iA nixos.git -q

# 克隆配置仓库
info "克隆配置仓库..."
mkdir -p /mnt/etc/nixos
cd /mnt/etc/nixos
git clone "$REPO_URL" .

# 运行安装脚本
info "运行安装脚本..."
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

success "安装配置完成！"
info "=========================================="
info "下一步操作:"
info "  1. 编辑 hosts/$HOSTNAME/hardware-configuration.nix"
info "     - 确认磁盘 UUID 和挂载点正确"
info "     - 如果使用加密，确保 luks 配置正确"
info "  2. 运行: nixos-install --flake .#$HOSTNAME"
info "  3. 重启系统: reboot"
info "=========================================="