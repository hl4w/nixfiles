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
    read -p "$1 (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

usage() {
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -y, --yes           自动确认所有提示"
    echo "  -s, --store         仅清理 Nix store"
    echo "  -g, --generations   仅清理旧系统版本"
    echo "  -a, --all           清理所有（默认）"
    exit 0
}

# 默认选项
CLEAN_STORE=true
CLEAN_GENERATIONS=true
NON_INTERACTIVE=false

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
        -s|--store)
            CLEAN_GENERATIONS=false
            shift
            ;;
        -g|--generations)
            CLEAN_STORE=false
            shift
            ;;
        -a|--all)
            CLEAN_STORE=true
            CLEAN_GENERATIONS=true
            shift
            ;;
        *)
            error "未知选项: $1"
            ;;
    esac
done

info "=========================================="
info "         NixOS Cleanup Utility"
info "=========================================="
echo

if [ "$NON_INTERACTIVE" = false ]; then
    info "即将执行以下清理操作:"
    if [ "$CLEAN_STORE" = true ]; then
        echo "  - 清理 Nix store 中不再被引用的包"
    fi
    if [ "$CLEAN_GENERATIONS" = true ]; then
        echo "  - 删除旧系统版本（保留最近3个）"
    fi
    echo
    if ! confirm "确认继续？"; then
        info "操作已取消"
        exit 0
    fi
fi

if [ "$CLEAN_STORE" = true ]; then
    info "清理 Nix store..."
    nix store gc --print-roots
    info "Nix store 清理完成"
fi

if [ "$CLEAN_GENERATIONS" = true ]; then
    info "清理旧系统版本..."
    sudo nix-collect-garbage -d
    info "旧版本清理完成"
fi

info "=========================================="
info "        清理完成！"
info "=========================================="