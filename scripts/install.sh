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

# 显式启用 flakes / nix-command
# 安装介质（ISO）或尚未启用 flakes 的系统，nix.conf 里通常没有这两个实验性特性，
# 直接执行 nix flake / nixos-install --flake 会报:
#   experimental Nix feature 'nix-command' is disabled
# 脚本内所有 nix 调用统一走该数组，不依赖目标环境的 nix.conf
NIX=(nix --extra-experimental-features "nix-command flakes")

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

# 把生成/修改的文件加入 Git 索引
# 本仓库是 Git 仓库，Nix 对 git 类型的 flake 只读取「已跟踪」的文件，
# 未经 git add 的新文件会直接报: Path '...' in the repository is not tracked by Git
git_track() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
    local path
    for path in "$@"; do
        if [ -e "$path" ]; then
            git add -- "$path" 2>/dev/null || true
        fi
    done
}

# 转义 sed 替换字符串中的特殊字符（/ & \）
# 避免用户名、邮箱、主机名等包含元字符时破坏 sed 替换
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
# 笔记本电源管理开关，默认关闭，由主机类型分支置为 true（避免未初始化变量）
POWER_MANAGEMENT="false"

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
            [ -n "${2:-}" ] || error "选项 $1 缺少用户名参数"
            USERNAME="$2"
            shift 2
            ;;
        -H|--hostname)
            [ -n "${2:-}" ] || error "选项 $1 缺少主机名参数"
            HOSTNAME="$2"
            shift 2
            ;;
        -G|--git-user)
            [ -n "${2:-}" ] || error "选项 $1 缺少 Git 用户名参数"
            GIT_USERNAME="$2"
            shift 2
            ;;
        -E|--git-email)
            [ -n "${2:-}" ] || error "选项 $1 缺少 Git 邮箱参数"
            GIT_EMAIL="$2"
            shift 2
            ;;
        -T|--host-type)
            [ -n "${2:-}" ] || error "选项 $1 缺少主机类型参数"
            HOST_TYPE_NAME="$2"
            shift 2
            ;;
        -W|--wm)
            [ -n "${2:-}" ] || error "选项 $1 缺少窗口管理器参数"
            WINDOW_MANAGER="$2"
            shift 2
            ;;
        -S|--shell)
            [ -n "${2:-}" ] || error "选项 $1 缺少桌面 Shell 参数"
            DESKTOP_SHELL="$2"
            shift 2
            ;;
        -P|--polkit-agent)
            [ -n "${2:-}" ] || error "选项 $1 缺少 polkit 代理参数"
            POLKIT_AGENT="$2"
            shift 2
            ;;
        -N|--name)
            [ -n "${2:-}" ] || error "选项 $1 缺少 flake 配置名称参数"
            FLAKE_NAME="$2"
            shift 2
            ;;
        *)
            error "未知选项: $1"
            ;;
    esac
done

info "=========================================="
info "       HL4W NixOS Configuration Installer"
info "=========================================="
echo

# 前置定位：切换到仓库根目录
# 脚本内所有路径（flake.nix、hosts/、home/、modules/）均相对仓库根目录；
# 若在其他目录执行（例如 sudo /path/to/scripts/install.sh），
# 会把主机配置写到错误位置，并在插入条目时失败，
# 最终表现为 flake does not provide attribute 'nixosConfigurations.<host>'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd)"
if [ -z "$REPO_ROOT" ] || [ ! -d "$REPO_ROOT" ]; then
    error "无法定位脚本所在目录: ${SCRIPT_DIR:-未知}"
fi
cd "$REPO_ROOT" || error "无法切换到仓库根目录: $REPO_ROOT"
info "工作目录: $REPO_ROOT"

# 仓库根目录结构校验，避免在残缺副本上继续执行
if [ ! -f flake.nix ] || [ ! -d hosts ] || [ ! -d home ]; then
    error "仓库结构不完整（缺少 flake.nix / hosts / home）: $REPO_ROOT"
fi

# 非交互模式：缺失的必需参数直接报错，绝不进入阻塞式输入
if [ "$NON_INTERACTIVE" = "true" ]; then
    [ -n "$USERNAME" ] || error "非交互模式必须通过 -U/--username 指定用户名"
    [ -n "$HOSTNAME" ] || error "非交互模式必须通过 -H/--hostname 指定主机名"
    [ -n "$HOST_TYPE_NAME" ] || error "非交互模式必须通过 -T/--host-type 指定主机类型"
    [ -n "$FLAKE_NAME" ] || FLAKE_NAME="$HOSTNAME"
    [ -n "$GIT_USERNAME" ] || GIT_USERNAME="$USERNAME"
    [ -n "$GIT_EMAIL" ] || GIT_EMAIL="$USERNAME@example.com"
    if [ "$HOST_TYPE_NAME" != "server" ]; then
        [ -n "$WINDOW_MANAGER" ] || error "非交互模式必须通过 -W/--wm 指定窗口管理器"
        [ -n "$DESKTOP_SHELL" ] || error "非交互模式必须通过 -S/--shell 指定桌面 Shell"
        [ -n "$POLKIT_AGENT" ] || POLKIT_AGENT="kde"
    fi
else
    # 交互式输入（如果没有通过参数提供）
    info "请输入以下配置信息:"
    echo
fi

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

# 统一校验取值合法性（交互输入与命令行参数都需校验）
case "$HOST_TYPE_NAME" in
    desktop|laptop|server) ;;
    *) error "无效的主机类型: $HOST_TYPE_NAME（可选: desktop/laptop/server）" ;;
esac

if [ "$HOST_TYPE_NAME" != "server" ]; then
    case "$WINDOW_MANAGER" in
        hyprland|niri) ;;
        *) error "无效的窗口管理器: $WINDOW_MANAGER（可选: hyprland/niri）" ;;
    esac
    case "$DESKTOP_SHELL" in
        dms|noctalia) ;;
        *) error "无效的桌面 Shell: $DESKTOP_SHELL（可选: dms/noctalia）" ;;
    esac
    case "$POLKIT_AGENT" in
        kde|hyprland) ;;
        *) error "无效的 polkit 代理: $POLKIT_AGENT（可选: kde/hyprland）" ;;
    esac
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
    info "检测到 Intel 集成显卡（使用内核默认驱动参数）"
else
    GPU_TYPE="unknown"
    info "未识别显卡类型，使用通用配置"
fi

echo "  GPU 类型：     ${GPU_TYPE}"
echo "------------------------------------------"

# =============================================
# 配置 flake.nix
# =============================================
info "配置 flake.nix..."
info "更新用户名..."
USERNAME_ESC=$(sed_escape_replacement "$USERNAME")
if grep -q 'USERNAME = "youruser"' flake.nix; then
    sed -i.bak "s/USERNAME = \"youruser\"/USERNAME = \"$USERNAME_ESC\"/g" flake.nix
    rm -f flake.nix.bak
    info "flake.nix 用户名已更新: $USERNAME"
else
    warn "flake.nix 中未找到 'youruser' 占位符，可能已被替换。跳过用户名更新。"
fi

# =============================================
# 创建主机配置目录
# =============================================
info "检查主机是否已存在..."
if [ -d "hosts/$HOSTNAME" ]; then
    warn "主机 $HOSTNAME 已存在，将更新配置"
    if confirm "是否覆盖现有配置？"; then
        info "备份现有配置..."
        mv "hosts/$HOSTNAME" "hosts/${HOSTNAME}_backup_$(date +%Y%m%d_%H%M%S)"
    else
        error "用户取消覆盖配置"
    fi
fi

info "创建主机配置目录..."
mkdir -p "hosts/$HOSTNAME"

# =============================================
# 生成主机 configuration.nix
# =============================================
info "生成主机 configuration.nix..."
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

# =============================================
# 创建用户 Home Manager 配置
# =============================================
info "创建用户 Home Manager 配置..."
mkdir -p "home/hosts"

# 检查是否已存在主机用户配置
if [ -f "home/hosts/$HOSTNAME.nix" ]; then
    warn "用户配置 $HOSTNAME.nix 已存在，将更新"
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
    # 导入用户级主题基础块（GTK/XDG 图标，无条件）
    echo "    ../common/theme-gtk.nix" >> "home/hosts/$HOSTNAME.nix"
    # 根据选择的窗口管理器导入对应配置 + WM 主题配色
    case $WINDOW_MANAGER in
        hyprland)
            echo "    ../common/hyprland.nix" >> "home/hosts/$HOSTNAME.nix"
            echo "    ../common/theme-hyprland.nix" >> "home/hosts/$HOSTNAME.nix"
            ;;
        niri)
            echo "    ../common/niri.nix" >> "home/hosts/$HOSTNAME.nix"
            echo "    ../common/theme-niri.nix" >> "home/hosts/$HOSTNAME.nix"
            ;;
    esac
fi

# 导入主机类型特定的用户级配置
echo "    ./$HOST_TYPE_NAME/default.nix" >> "home/hosts/$HOSTNAME.nix"

echo "  ];" >> "home/hosts/$HOSTNAME.nix"
echo "}" >> "home/hosts/$HOSTNAME.nix"

# =============================================
# 更新用户相关配置
# =============================================

info "更新 Git 配置..."

GIT_USERNAME_ESC=$(sed_escape_replacement "$GIT_USERNAME")
GIT_EMAIL_ESC=$(sed_escape_replacement "$GIT_EMAIL")

# 检查并替换 git.nix 中的 Git 用户名占位符
# 使用精确模式（含字段名 userName）避免误匹配，并支持幂等运行
if grep -q 'userName = "Your Name"' home/common/git.nix; then
    sed -i.bak "s/userName = \"Your Name\"/userName = \"$GIT_USERNAME_ESC\"/" home/common/git.nix
    rm -f home/common/git.nix.bak
    info "Git 用户名已更新: $GIT_USERNAME"
else
    warn "git.nix 中未找到 'Your Name' 占位符，可能已被替换。跳过用户名更新。"
    warn "如需修改 Git 用户名，请手动编辑 home/common/git.nix 中的 userName 字段"
fi

# 检查并替换 git.nix 中的 Git 邮箱占位符
if grep -q 'userEmail = "your.email@example.com"' home/common/git.nix; then
    sed -i.bak "s/userEmail = \"your.email@example.com\"/userEmail = \"$GIT_EMAIL_ESC\"/" home/common/git.nix
    rm -f home/common/git.nix.bak
    info "Git 邮箱已更新: $GIT_EMAIL"
else
    warn "git.nix 中未找到 'your.email@example.com' 占位符，可能已被替换。跳过邮箱更新。"
    warn "如需修改 Git 邮箱，请手动编辑 home/common/git.nix 中的 userEmail 字段"
fi

info "更新用户相关占位符..."

# 用户名可能包含 sed 元字符，必须先转义才能安全用于替换串
for target in hosts/common/default.nix modules/services/virtualisation.nix; do
    if [ ! -f "$target" ]; then
        warn "文件不存在，跳过: $target"
        continue
    fi
    if grep -q 'youruser' "$target"; then
        sed -i.bak "s/youruser/${USERNAME_ESC}/g" "$target"
        rm -f "${target}.bak"
        # 替换后校验，避免静默失败
        if grep -q 'youruser' "$target"; then
            error "用户名占位符替换失败: $target"
        fi
        info "用户名占位符已更新: $target"
    else
        info "未找到 'youruser' 占位符，跳过: $target"
    fi
done

# =============================================
# 配置 flake.nix 主机输出
# =============================================
info "配置 flake.nix 添加新主机..."

# FLAKE_NAME 作为 nix 属性名必须加引号
# 否则含连字符的名称（如 my-desktop）会被 nix 解析为减法运算，导致语法错误
FLAKE_ENTRY="      \"${FLAKE_NAME}\" = mkHost \"${HOSTNAME}\";"

# 检查是否已存在该主机配置（使用引号包裹的属性名精确匹配）
if grep -qF "\"${FLAKE_NAME}\" = mkHost" flake.nix; then
    warn "主机 $FLAKE_NAME 已存在于 flake.nix 中"
    if confirm "是否更新现有配置？"; then
        # 删除旧配置行
        sed -i.bak "/\"${FLAKE_NAME}\" = mkHost/d" flake.nix
        rm -f flake.nix.bak
        # 插入新配置行（使用 awk 避免 sed 'a' 命令的跨版本兼容性问题）
        awk -v entry="$FLAKE_ENTRY" 'index($0, "nixosConfigurations = {") {print; print entry; next} {print}' flake.nix > flake.nix.tmp && mv flake.nix.tmp flake.nix
        info "主机配置已更新: \"${FLAKE_NAME}\" = mkHost \"${HOSTNAME}\""
    else
        error "用户取消更新配置"
    fi
else
    # 添加新主机配置
    awk -v entry="$FLAKE_ENTRY" 'index($0, "nixosConfigurations = {") {print; print entry; next} {print}' flake.nix > flake.nix.tmp && mv flake.nix.tmp flake.nix
    info "已添加主机配置: \"${FLAKE_NAME}\" = mkHost \"${HOSTNAME}\""
fi

# 验证插入是否成功
if grep -qF "\"${FLAKE_NAME}\" = mkHost" flake.nix; then
    info "flake.nix 主机配置验证成功"
else
    error "flake.nix 主机配置插入失败，请手动检查 flake.nix 中的 nixosConfigurations 块"
fi

# 生成的新文件必须加入 Git 索引，否则 nix 读取 flake 时会报 not tracked by Git
git_track flake.nix "hosts/$HOSTNAME/configuration.nix" "home/hosts/$HOSTNAME.nix" hosts/common/default.nix home/common/git.nix

# =============================================
# 生成 flake.lock
# =============================================
info "生成 flake.lock..."
"${NIX[@]}" flake lock
git_track flake.lock

# =============================================
# 生成硬件配置
# =============================================
echo
if confirm "是否立即生成硬件配置？(需要 sudo 权限)"; then
    info "生成硬件配置..."
    if command -v nixos-generate-config &> /dev/null; then
        # 安装介质场景下目标系统根目录挂载在 /mnt，
        # 必须传入 --root /mnt 才能探测到正确的挂载点与 UUID
        GEN_ARGS=(--show-hardware-config)
        if [ -d /mnt/etc ] && mountpoint -q /mnt 2>/dev/null; then
            GEN_ARGS=(--root /mnt --show-hardware-config)
        fi

        if sudo nixos-generate-config "${GEN_ARGS[@]}" > "hosts/$HOSTNAME/hardware-configuration.nix"; then
            info "硬件配置已生成: hosts/$HOSTNAME/hardware-configuration.nix"
            info "建议检查并编辑硬件配置文件，确保磁盘 UUID 和挂载点正确"
            git_track "hosts/$HOSTNAME/hardware-configuration.nix"
        else
            error "生成硬件配置失败，请手动运行: sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
        fi
    else
        warn "nixos-generate-config 命令不可用（可能不在 NixOS 安装介质中）"
        info "请在 NixOS 安装介质中运行以下命令:"
        info "  sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
        info "  git add hosts/$HOSTNAME/hardware-configuration.nix   # Nix 只读取已跟踪文件"
        exit 1
    fi
else
    info "跳过自动生成硬件配置"
    warn "⚠️  硬件配置文件尚未创建!"
    info "请在 NixOS 安装介质中手动生成:"
    info "  sudo nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
    info "  git add hosts/$HOSTNAME/hardware-configuration.nix   # Nix 只读取已跟踪文件"
fi

# =============================================
# 验证配置
# =============================================
echo
if confirm "是否验证配置是否正确？"; then
    info "验证 flake 配置..."
    # 兜底：确保所有生成文件都已跟踪，避免 "Path ... is not tracked by Git"
    git_track "hosts/$HOSTNAME" "home/hosts/$HOSTNAME.nix" flake.nix flake.lock
    if "${NIX[@]}" flake check; then
        info "✅ flake 配置验证通过"
    else
        warn "❌ flake 配置验证失败，请检查错误信息"
    fi
fi

# =============================================
# 完成信息
# =============================================
echo
info "=========================================="
info "         配置完成!"
info "=========================================="
echo
info "项目已配置完成，可以使用以下命令更新系统:"
echo "------------------------------------------"
echo ""
echo "📦 系统更新命令:"
echo "------------------------------------------"
echo "# 修改 modules/ 目录后更新系统:"
echo "  sudo nixos-rebuild switch --flake .#$FLAKE_NAME"
echo ""
echo "# 修改 home/ 目录后更新用户配置:"
echo "  home-manager switch --flake .#$USERNAME@$FLAKE_NAME"
echo ""
echo "# 更新 flake 依赖（升级 nixpkgs 等）:"
echo "  nix flake update"
echo ""
echo "# 一键更新脚本（推荐）:"
echo "  ./scripts/update.sh"
echo ""
echo "🔧 验证命令:"
echo "------------------------------------------"
echo "# 检查配置语法:"
echo "  nix flake check"
echo ""
echo "# 测试构建（不部署）:"
echo "  nix build .#nixosConfigurations.\"$FLAKE_NAME\".config.system.build.toplevel"
echo ""
echo "# 回滚到上一代:"
echo "  sudo nixos-rebuild switch --rollback"
echo ""
echo "# 如提示 experimental Nix feature 'nix-command' is disabled，请将命令写成:"
echo "  nix --extra-experimental-features \"nix-command flakes\" flake lock"
echo ""
echo "📝 后续步骤:"
echo "------------------------------------------"
echo "1. 确保硬件配置已生成并已加入 Git 索引:"
echo "   hosts/$HOSTNAME/hardware-configuration.nix"
echo "   git add hosts/$HOSTNAME"
echo ""
echo "2. 编辑 hardware-configuration.nix，确认:"
echo "   - 根分区 device 指向正确的磁盘/分区"
echo "   - boot 分区挂载点正确"
echo "   - swap 配置正确"
echo ""
echo "3. 在 NixOS 安装介质中部署系统:"
echo "   sudo nixos-rebuild switch --flake .#$FLAKE_NAME"
echo ""
echo "4. 部署后更新 Home Manager:"
echo "   home-manager switch --flake .#$USERNAME@$FLAKE_NAME"
echo "------------------------------------------"
echo
info "提示: 安装完成后，您可以随时修改 modules/ 或 home/ 目录中的文件,"
info "然后运行 'sudo nixos-rebuild switch --flake .#$FLAKE_NAME' 来应用更改!"
