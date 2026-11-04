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
    echo "说明:"
    echo "  未指定 -T/-W/-S 时，在交互终端中会提示选择（直接回车使用默认值）；"
    echo "  使用 -y 或 stdin 非终端时按默认值 desktop/hyprland/dms 处理。"
    echo
    echo "示例:"
    echo "  $0 -y /dev/nvme0n1 my-desktop john"
    echo "  $0 -y -T desktop -W hyprland -S dms /dev/nvme0n1 my-desktop john"
    exit 0
}

# 根据设备名推导分区名：nvme/mmcblk/loop 需要 p1，sda/vda 直接用 1
part_name() {
    local disk="$1" index="$2"
    case "$disk" in
        /dev/nvme*|/dev/mmcblk*|/dev/loop*) echo "${disk}p${index}" ;;
        *) echo "${disk}${index}" ;;
    esac
}

# 校验显式传入的取值是否在允许列表内
# 用法: validate_choice <名称> <取值> <允许值...>
validate_choice() {
    local name="$1" value="$2"
    shift 2
    local allowed
    for allowed in "$@"; do
        [ "$value" = "$allowed" ] && return 0
    done
    error "$name 取值无效: $value（可选: $*）"
}

# 交互式选择：仅在交互终端且非 -y 模式时提示，结果输出到 stdout
# 用法: prompt_choice <提示语> <默认值> <可选值...>
prompt_choice() {
    local prompt="$1" default="$2" choice opt i
    shift 2
    local options=("$@")

    # 非交互模式或 stdin 不是终端时直接返回默认值，避免自动化流程卡住
    if [ "$NON_INTERACTIVE" = true ] || [ ! -t 0 ]; then
        warn "未指定，使用默认值: $default" >&2
        echo "$default"
        return 0
    fi

    while true; do
        echo -e "${YELLOW}${prompt}${NC}" >&2
        i=1
        for opt in "${options[@]}"; do
            if [ "$opt" = "$default" ]; then
                echo "  $i) $opt（默认）" >&2
            else
                echo "  $i) $opt" >&2
            fi
            i=$((i + 1))
        done
        printf "请选择 [1-%d，直接回车使用默认值 %s]: " "${#options[@]}" "$default" >&2
        read -r choice || choice=""

        # 空输入：使用默认值
        if [ -z "$choice" ]; then
            echo "$default"
            return 0
        fi
        # 数字编号
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            echo "${options[$((choice - 1))]}"
            return 0
        fi
        # 直接输入名称
        for opt in "${options[@]}"; do
            if [ "$choice" = "$opt" ]; then
                echo "$opt"
                return 0
            fi
        done
        warn "无效选择: $choice，请重新输入" >&2
    done
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
            [ -n "${2:-}" ] || error "选项 $1 缺少参数"
            REPO_URL="$2"
            shift 2
            ;;
        -T|--host-type)
            [ -n "${2:-}" ] || error "选项 $1 缺少参数"
            HOST_TYPE="$2"
            shift 2
            ;;
        -W|--wm)
            [ -n "${2:-}" ] || error "选项 $1 缺少参数"
            WINDOW_MANAGER="$2"
            shift 2
            ;;
        -S|--shell)
            [ -n "${2:-}" ] || error "选项 $1 缺少参数"
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
    echo "错误: 缺少必需参数" >&2
    echo >&2
    usage
fi

DISK="$1"
TARGET_HOSTNAME="$2"
TARGET_USERNAME="$3"

# 前置校验：root 权限、设备存在且为块设备
if [ "$(id -u)" != "0" ]; then
    error "必须以 root 用户运行此脚本"
fi

[ -e "$DISK" ] || error "磁盘设备不存在: $DISK"
[ -b "$DISK" ] || error "指定的路径不是块设备: $DISK"

# 校验显式传入的取值，避免把非法值静默传给 install.sh
if [ -n "$HOST_TYPE" ]; then
    validate_choice "主机类型" "$HOST_TYPE" desktop laptop server
fi
if [ -n "$WINDOW_MANAGER" ]; then
    validate_choice "窗口管理器" "$WINDOW_MANAGER" hyprland niri
fi
if [ -n "$DESKTOP_SHELL" ]; then
    validate_choice "桌面 Shell" "$DESKTOP_SHELL" dms noctalia
fi

# 未显式指定时：交互终端内让用户选择；
# 使用 -y 或 stdin 非终端时回落到推荐默认值，避免安装流程中断
# （install.sh 以非交互模式运行，不会再次提问）
if [ -z "$HOST_TYPE" ]; then
    HOST_TYPE="$(prompt_choice "选择主机类型" desktop desktop laptop server)"
fi
if [ "$HOST_TYPE" != "server" ]; then
    if [ -z "$WINDOW_MANAGER" ]; then
        WINDOW_MANAGER="$(prompt_choice "选择窗口管理器" hyprland hyprland niri)"
    fi
    if [ -z "$DESKTOP_SHELL" ]; then
        DESKTOP_SHELL="$(prompt_choice "选择桌面 Shell" dms dms noctalia)"
    fi
fi

# 显示配置摘要
info "=========================================="
info "      HL4W NixOS Disk Setup Utility"
info "=========================================="
echo
info "配置参数:"
info "  磁盘设备:      $DISK"
info "  主机名:        $TARGET_HOSTNAME"
info "  用户名:        $TARGET_USERNAME"
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

# 卸载可能已挂载的分区
info "卸载已挂载的分区..."
swapoff -a 2>/dev/null || true
umount -R /mnt 2>/dev/null || true
vgchange -an vg 2>/dev/null || true
cryptsetup luksClose cryptroot 2>/dev/null || true

# 创建分区表
info "创建 GPT 分区表..."
parted -s "$DISK" -- mklabel gpt

# 创建 EFI 分区 (512MiB)
info "创建 EFI 分区..."
parted -s "$DISK" -- mkpart ESP fat32 1MiB 512MiB
parted -s "$DISK" -- set 1 esp on

# 创建数据分区（加密时整盘作为 LUKS 容器，非加密时直接作为 LVM 物理卷）
info "创建数据分区..."
parted -s "$DISK" -- mkpart primary 512MiB 100%

# 通知内核刷新分区表
partprobe "$DISK" 2>/dev/null || true
udevadm settle

EFI_PART="$(part_name "$DISK" 1)"
DATA_PART="$(part_name "$DISK" 2)"

info "EFI 分区:  $EFI_PART"
info "数据分区: $DATA_PART"

[ -b "$EFI_PART" ] || error "EFI 分区设备未出现: $EFI_PART"
[ -b "$DATA_PART" ] || error "数据分区设备未出现: $DATA_PART"

# 格式化 EFI 分区
info "格式化 EFI 分区..."
mkfs.fat -F 32 -n BOOT "$EFI_PART"

if [ "$USE_ENCRYPTION" = true ]; then
    # 读取并确认加密密码，避免输入错误导致系统无法启动
    read -rsp "输入加密密码: " CRYPT_PASSWORD
    echo
    read -rsp "再次确认密码: " CRYPT_PASSWORD_CONFIRM
    echo

    if [ "$CRYPT_PASSWORD" != "$CRYPT_PASSWORD_CONFIRM" ]; then
        error "两次输入的密码不一致"
    fi
    [ -n "$CRYPT_PASSWORD" ] || error "加密密码不能为空"

    info "创建加密分区..."
    printf '%s' "$CRYPT_PASSWORD" | cryptsetup luksFormat -q --type=luks2 --key-file=- "$DATA_PART"
    printf '%s' "$CRYPT_PASSWORD" | cryptsetup luksOpen --key-file=- "$DATA_PART" cryptroot
    unset CRYPT_PASSWORD CRYPT_PASSWORD_CONFIRM

    PV_DEV="/dev/mapper/cryptroot"
else
    info "非加密模式：直接在数据分区上创建 LVM 物理卷"
    PV_DEV="$DATA_PART"
fi

# 两种模式统一使用 LVM：/ 与 swap 均为逻辑卷，/home 位于 / 下，不再划分独立分区
info "创建 LVM 物理卷与卷组..."
pvcreate -y "$PV_DEV"
vgcreate vg "$PV_DEV"

# swap 大小随磁盘容量调整：取磁盘容量的 10%，限制在 2GiB~16GiB
PV_SIZE_BYTES="$(blockdev --getsize64 "$PV_DEV")"
SWAP_MB=$(( PV_SIZE_BYTES / 1024 / 1024 / 10 ))
if [ "$SWAP_MB" -gt 16384 ]; then
    SWAP_MB=16384
fi
if [ "$SWAP_MB" -lt 2048 ]; then
    SWAP_MB=2048
fi

info "创建逻辑卷 (swap ${SWAP_MB}MiB / root 占满剩余空间)..."
lvcreate -y -L "${SWAP_MB}M" vg -n swap
lvcreate -y -l 100%FREE vg -n root

ROOT_DEV="/dev/vg/root"
SWAP_DEV="/dev/vg/swap"

for dev in "$ROOT_DEV" "$SWAP_DEV"; do
    [ -b "$dev" ] || error "逻辑卷未出现: $dev"
done

# 格式化文件系统（每个设备只格式化一次）
info "格式化文件系统..."
mkfs.ext4 -F -L nixos "$ROOT_DEV"
mkswap -L swap "$SWAP_DEV"

# 挂载分区
info "挂载分区..."
mount "$ROOT_DEV" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot

# swap 使用 LVM 逻辑卷
swapon "$SWAP_DEV"

success "分区和挂载完成！"

# 安装 git（安装介质通常已自带）
if ! command -v git &> /dev/null; then
    info "安装 git..."
    nix-env -iA nixos.git -q
fi

# 克隆配置仓库
info "克隆配置仓库..."
mkdir -p /mnt/etc/nixos
cd /mnt/etc/nixos
if [ -d .git ]; then
    info "检测到已有仓库，执行 git pull..."
    git pull --ff-only
else
    git clone "$REPO_URL" .
fi

# 运行安装脚本（使用数组传参，避免 eval 注入）
info "运行安装脚本..."
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

success "安装配置完成！"
info "=========================================="
info "配置仓库位置: /mnt/etc/nixos（已由脚本自动克隆并生成主机配置）"
info "=========================================="
info "下一步操作（在 /mnt/etc/nixos 下执行）:"
info "  1. 检查 hosts/$TARGET_HOSTNAME/hardware-configuration.nix"
info "     - 确认磁盘 UUID 和挂载点正确"
info "     - 如果使用加密，确保 luks 配置正确"
info "  2. 安装系统:"
info "       cd /mnt/etc/nixos"
info "       sudo nixos-install --flake .#$TARGET_HOSTNAME"
info "  3. 重启系统: reboot"
info "=========================================="
