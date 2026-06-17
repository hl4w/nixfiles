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
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -y, --yes           非交互式模式，自动确认所有提示"
    exit 0
}

# 默认值
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
        *)
            error "未知选项: $1"
            ;;
    esac
done

info "=========================================="
info "      HL4W Direnv Setup Utility"
info "=========================================="
echo

info "初始化 direnv..."
if ! command -v direnv &> /dev/null; then
    warn "direnv 未安装，将尝试安装..."
    nix-env -iA nixos.direnv -q
fi

info "允许当前目录的 direnv 配置..."
direnv allow

info "配置 Shell hook..."

# 检测当前 Shell
SHELL_NAME=$(basename "$SHELL")

case "$SHELL_NAME" in
    zsh)
        HOOK_FILE="$HOME/.zshrc"
        HOOK_LINE='eval "$(direnv hook zsh)"'
        ;;
    bash)
        HOOK_FILE="$HOME/.bashrc"
        HOOK_LINE='eval "$(direnv hook bash)"'
        ;;
    fish)
        HOOK_FILE="$HOME/.config/fish/config.fish"
        HOOK_LINE='direnv hook fish | source'
        ;;
    *)
        warn "未知 Shell: $SHELL_NAME"
        info "请手动添加 direnv hook 到您的 Shell 配置文件"
        exit 0
        ;;
esac

# 检查是否已存在 hook
if grep -q "direnv hook" "$HOOK_FILE" 2>/dev/null; then
    info "direnv hook 已配置在 $HOOK_FILE"
else
    info "添加 direnv hook 到 $HOOK_FILE..."
    echo "$HOOK_LINE" >> "$HOOK_FILE"
    info "已添加 direnv hook"
fi

echo
info "=========================================="
info "           配置完成!"
info "=========================================="
echo
info "请重启终端或运行以下命令使配置生效:"
echo "  source $HOOK_FILE"