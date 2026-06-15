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

echo "Updating flake..."
nix flake update

echo "Building configuration..."
# 使用当前主机名进行构建
if [ -n "$HOSTNAME" ]; then
    nix build .#"$HOSTNAME"
else
    # 默认使用 desktop 主机配置
    nix build .#desktop
fi

echo "Update completed successfully!"