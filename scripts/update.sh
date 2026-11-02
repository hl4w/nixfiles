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

usage() {
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -H, --hostname      指定主机名（默认使用当前主机名）"
    echo
    echo "示例:"
    echo "  $0"
    echo "  $0 -H my-desktop"
    exit 0
}

# 默认值：优先使用 $HOSTNAME，退化到 hostname 命令
TARGET_HOSTNAME="${HOSTNAME:-$(hostname 2>/dev/null || true)}"
# 当前用户：用于生成 Home Manager 命令提示
CURRENT_USER="${USER:-$(id -un)}"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -H|--hostname)
            if [ -z "${2:-}" ]; then
                error "选项 $1 缺少主机名参数"
            fi
            TARGET_HOSTNAME="$2"
            shift 2
            ;;
        *)
            error "未知选项: $1"
            ;;
    esac
done

if [ -z "$TARGET_HOSTNAME" ]; then
    error "无法确定主机名，请使用 -H <hostname> 指定"
fi

info "=========================================="
info "        HL4W NixOS Update Utility"
info "=========================================="
echo

info "更新 flake 依赖..."
nix flake update

info "构建系统配置..."
info "目标主机: $TARGET_HOSTNAME"
# nixosConfigurations 的构建产物需走完整属性路径；
# `nix build .#host` 只在 flakes 暴露 packages.<system>.<host> 时才有效
nix build ".#nixosConfigurations.\"${TARGET_HOSTNAME}\".config.system.build.toplevel"

echo
info "=========================================="
info "           更新完成!"
info "=========================================="
echo
info "接下来可以运行以下命令部署更新:"
echo "  sudo nixos-rebuild switch --flake .#$TARGET_HOSTNAME"
echo "  home-manager switch --flake .#$CURRENT_USER@$TARGET_HOSTNAME"