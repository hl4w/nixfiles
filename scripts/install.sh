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
    if [ "$NON_INTERACTIVE" = "true" ]; then
        return 0
    fi
    read -p "$1 (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

usage() {
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -y, --yes           非交互式模式，自动确认所有提示"
    echo "  -U, --username      指定用户名"
    echo "  -H, --hostname      指定主机名"
    echo "  -G, --git-user      指定 Git 用户名"
    echo "  -E, --git-email     指定 Git 邮箱"
    echo "  -T, --host-type     指定主机类型: desktop/laptop/server"
    echo "  -W, --wm            指定窗口管理器: hyprland/niri (仅桌面/笔记本)"
    echo "  -S, --shell         指定桌面 Shell: dms/noctalia (仅桌面/笔记本)"
    echo "  -P, --polkit-agent  指定 polkit 代理: kde/hyprland (仅桌面/笔记本，默认 kde)"
    echo "  -N, --name          指定 flake 配置名称（默认使用主机名）"
    echo
    echo "示例:"
    echo "  $0 -y -U john -H my-desktop -N my-desktop-config -T desktop -W hyprland -S dms -P kde"
    exit 0
}

# 默认值
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

# 解析命令行参数
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
            error "未知选项: $1"
            ;;
    esac
done

info "=========================================="
info "       NixOS Configuration Installer"
info "=========================================="
echo

# 交互式输入（如果没有通过参数提供）
info "请输入以下配置信息:"
echo

if [ -z "$USERNAME" ]; then
    read -p "用户名：" -e USERNAME
    if [ -z "$USERNAME" ]; then
        error "用户名不能为空"
    fi
fi

if [ -z "$HOSTNAME" ]; then
    read -p "主机名：" -e HOSTNAME
    if [ -z "$HOSTNAME" ]; then
        error "主机名不能为空"
    fi
fi

if [ -z "$FLAKE_NAME" ]; then
    read -p "Flake 配置名称（默认使用主机名）：" -e FLAKE_NAME
    if [ -z "$FLAKE_NAME" ]; then
        FLAKE_NAME="$HOSTNAME"
        info "使用主机名作为 flake 配置名称: $FLAKE_NAME"
    fi
fi

if [ -z "$GIT_USERNAME" ]; then
    read -p "Git 用户名：" -e GIT_USERNAME
    if [ -z "$GIT_USERNAME" ]; then
        warn "Git 用户名为空，将使用默认值"
        GIT_USERNAME="$USERNAME"
    fi
fi

if [ -z "$GIT_EMAIL" ]; then
    read -p "Git 邮箱：" -e GIT_EMAIL
    if [ -z "$GIT_EMAIL" ]; then
        warn "Git 邮箱为空，将使用默认值"
        GIT_EMAIL="$USERNAME@example.com"
    fi
fi

if [ -z "$HOST_TYPE_NAME" ]; then
    echo
    info "选择主机类型:"
    echo "  1) Desktop (台式机 - 高性能硬件)"
    echo "  2) Laptop (笔记本 - 电池管理、触摸板)"
    echo "  3) Server (服务器 - 无桌面环境)"
    read -p "请输入选择 (1/2/3): " -e HOST_TYPE
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
            error "无效选择"
            ;;
    esac
fi

if [ "$HOST_TYPE_NAME" != "server" ]; then
    if [ -z "$WINDOW_MANAGER" ]; then
        echo
        info "选择窗口管理器:"
        echo "  1) Hyprland (动态平铺，推荐)"
        echo "  2) Niri (现代平铺，适合笔记本)"
        read -p "请输入选择 (1/2): " -e WM_CHOICE
        case $WM_CHOICE in
            1)
                WINDOW_MANAGER="hyprland"
                ;;
            2)
                WINDOW_MANAGER="niri"
                ;;
            *)
                error "无效选择"
                ;;
        esac
    fi

    if [ -z "$DESKTOP_SHELL" ]; then
        echo
        info "选择桌面 Shell:"
        echo "  1) DMS-Shell (轻量级显示管理器 Shell)"
        echo "  2) Noctalia-Shell (现代化桌面集成 Shell)"
        read -p "请输入选择 (1/2): " -e SHELL_CHOICE
        case $SHELL_CHOICE in
            1)
                DESKTOP_SHELL="dms"
                ;;
            2)
                DESKTOP_SHELL="noctalia"
                ;;
            *)
                error "无效选择"
                ;;
        esac
    fi

    if [ -z "$POLKIT_AGENT" ]; then
        echo
        info "选择 polkit 代理:"
        echo "  1) KDE (polkit-kde-agent-1，功能完整，推荐)"
        echo "  2) Hyprland (hyprpolkitagent，更轻量)"
        read -p "请输入选择 (1/2，默认 1): " -e POLKIT_CHOICE
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
info "配置摘要:"
echo "------------------------------------------"
echo "用户名：        $USERNAME"
echo "主机名：        $HOSTNAME"
echo "Flake 名称:      $FLAKE_NAME"
echo "主机类型：      $HOST_TYPE_NAME"
echo "窗口管理器：    ${WINDOW_MANAGER:-无}"
echo "桌面 Shell:      ${DESKTOP_SHELL:-无}"
echo "polkit 代理:     ${POLKIT_AGENT:-无}"
echo "Git 用户名：    $GIT_USERNAME"
echo "Git 邮箱：      $GIT_EMAIL"
echo "------------------------------------------"

if ! confirm "确认以上配置是否正确？"; then
    error "用户取消安装"
fi

echo
info "开始配置项目..."

# =============================================
# GPU 硬件检测
# =============================================
info "检测 GPU 硬件..."

GPU_TYPE=""
GPU_KERNEL_PARAMS=""
GPU_IMPORTS=""

# 检测 NVIDIA 显卡
if lspci 2>/dev/null | grep -qi "nvidia"; then
    GPU_TYPE="nvidia"
    info "检测到 NVIDIA 显卡"
    GPU_IMPORTS="    ../../modules/hardware/nvidia.nix"
    GPU_KERNEL_PARAMS='
  # NVIDIA 显卡配置
  boot.kernelParams = [
    "nvidia_drm.modeset=1"
    "nvidia_drm.fbdev=1"
  ];'
# 检测 AMD 显卡
elif lspci 2>/dev/null | grep -qiE "(vga|3d).*amd|ati|radeon"; then
    GPU_TYPE="amd"
    info "检测到 AMD/ATI 显卡"
    GPU_KERNEL_PARAMS='
  boot.kernelParams = [
    "amdgpu.si_support=1"
    "amdgpu.cik_support=1"
  ];'
# 检测 Intel 集成显卡
elif lspci 2>/dev/null | grep -qiE "(vga|3d).*intel"; then
    GPU_TYPE="intel"
    info "检测到 Intel 集成显卡"
    GPU_KERNEL_PARAMS='
  boot.kernelParams = [
    "i915.enable_psr=0"
  ];'
else
    GPU_TYPE="unknown"
    info "未识别显卡类型，使用通用配置"
fi

echo "  GPU 类型：     ${GPU_TYPE}"
echo "------------------------------------------"

info "更新 flake.nix 用户名..."
sed -i.bak "s/USERNAME = \"youruser\"/USERNAME = \"$USERNAME\"/g" flake.nix
rm -f flake.nix.bak

info "检查主机是否已存在..."
if [ -d "hosts/$HOSTNAME" ]; then
    warn "主机 $HOSTNAME 已存在，将更新配置"
fi

info "创建主机配置目录..."
mkdir -p "hosts/$HOSTNAME"

info "配置主机 configuration.nix..."
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

# 添加 NVIDIA 模块导入
if [ "$GPU_TYPE" = "nvidia" ]; then
    echo "$GPU_IMPORTS" >> "hosts/$HOSTNAME/configuration.nix"
fi

cat >> "hosts/$HOSTNAME/configuration.nix" << EOF
  ];

  networking.hostName = "$HOSTNAME";
EOF

# 添加 GPU 内核参数
if [ -n "$GPU_KERNEL_PARAMS" ]; then
    echo "$GPU_KERNEL_PARAMS" >> "hosts/$HOSTNAME/configuration.nix"
fi

# 添加桌面配置选项（仅桌面/笔记本）
if [ "$HOST_TYPE_NAME" != "server" ]; then
    cat >> "hosts/$HOSTNAME/configuration.nix" << EOF

  # 桌面配置
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

info "创建用户 Home Manager 配置..."
mkdir -p "home/hosts"
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
# 导入主机类型特定的用户级配置
echo "    ./$HOST_TYPE_NAME/default.nix" >> "home/hosts/$HOSTNAME.nix"

echo "  ];" >> "home/hosts/$HOSTNAME.nix"

echo "}" >> "home/hosts/$HOSTNAME.nix"

info "更新 Git 配置..."
sed -i.bak "s/Your Name/$GIT_USERNAME/g" home/common/git.nix
sed -i.bak "s/your.email@example.com/$GIT_EMAIL/g" home/common/git.nix
rm -f home/common/git.nix.bak

info "更新 hosts/common/default.nix 用户配置..."
sed -i.bak "s/youruser/$USERNAME/g" hosts/common/default.nix
rm -f hosts/common/default.nix.bak

info "更新 flake.nix 添加新主机..."
if ! grep -q "$FLAKE_NAME = mkHost" flake.nix; then
    sed -i.bak "/nixosConfigurations = {/a \\      $FLAKE_NAME = mkHost \"$HOSTNAME\";\\\n" flake.nix
fi
rm -f flake.nix.bak

info "更新 virtualisation 模块..."
sed -i.bak "s/youruser/$USERNAME/g" modules/services/virtualisation.nix
rm -f modules/services/virtualisation.nix.bak

info "生成 flake.lock..."
nix flake lock

echo
if confirm "是否立即生成硬件配置？(需要 sudo 权限)"; then
    info "生成硬件配置..."
    if command -v nixos-generate-config &> /dev/null; then
        if sudo nixos-generate-config --show-hardware-config > "hosts/$HOSTNAME/hardware-configuration.nix"; then
            info "硬件配置已生成: hosts/$HOSTNAME/hardware-configuration.nix"
            info "建议检查并编辑硬件配置文件，确保磁盘 UUID 和挂载点正确"
        else
            error "生成硬件配置失败，请手动运行:"
            error "  sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
        fi
    else
        error "nixos-generate-config 命令不可用（可能不在 NixOS 安装介质中）"
        info "请在 NixOS 安装介质中运行以下命令:"
        info "  sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
    fi
else
    info "跳过自动生成硬件配置"
    warn "⚠️  硬件配置文件尚未创建!"
    info "请在 NixOS 安装介质中手动生成:"
    info "  sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
fi

echo
info "=========================================="
info "         配置完成!"
info "=========================================="
echo
info "下一步操作:"
echo "------------------------------------------"
echo "1. 生成硬件配置（如未自动生成）:"
echo "   sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
echo ""
echo "2. 编辑 hardware-configuration.nix，更新磁盘 UUID"
echo "   vim hosts/$HOSTNAME/hardware-configuration.nix"
echo "   - 确保根分区 device 指向正确的磁盘/分区"
echo "   - 检查 boot 分区挂载点"
echo "   - 确认 swap 配置正确"
echo ""
echo "3. 构建配置:"
echo "   nix build .#$FLAKE_NAME"
echo ""
echo "4. 部署系统:"
echo "   sudo nixos-rebuild switch --flake .#$FLAKE_NAME"
echo ""
echo "5. 更新 Home Manager:"
echo "   home-manager switch --flake .#$USERNAME@$FLAKE_NAME"
echo "------------------------------------------"