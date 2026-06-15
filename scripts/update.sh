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

# 默认值
TARGET_HOSTNAME="$HOSTNAME"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -H|--hostname)
            TARGET_HOSTNAME="$2"
            shift 2
            ;;
        *)
            error "未知选项: $1"
            ;;
    esac
done

info "=========================================="
info "        HL4W NixOS Update Utility"
info "=========================================="
echo

info "更新 flake 依赖..."
nix flake update

info "构建系统配置..."
if [ -n "$TARGET_HOSTNAME" ]; then
    info "目标主机: $TARGET_HOSTNAME"
    nix build .#"$TARGET_HOSTNAME"
else
    warn "未指定主机名，使用默认配置"
    nix build .#desktop
fi

echo
info "=========================================="
info "           更新完成!"
info "=========================================="
echo
info "接下来可以运行以下命令部署更新:"
echo "  sudo nixos-rebuild switch --flake .#$TARGET_HOSTNAME"
echo "  home-manager switch --flake .#$USER@$TARGET_HOSTNAME"