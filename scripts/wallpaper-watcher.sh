#!/usr/bin/env bash
# Author: Silas Zhang (2026)
# shellcheck shell=bash
# 壁纸变化监听器
# 当壁纸文件变化时自动触发配色更新

# NixOS compatibility
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

# 配置变量
WALLPAPER_DIR="${HOME}/.wallpapers"
WAL_CACHE="${HOME}/.cache/wal"
CURRENT_WALLPAPER_FILE="${WAL_CACHE}/wal"
WATCH_INTERVAL=2  # 检查间隔（秒）
LAST_TRIGGER_TIME=0

info() {
    echo -e "${GREEN}[WATCHER]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WATCHER WARN]${NC} $1"
}

error() {
    echo -e "${RED}[WATCHER ERROR]${NC} $1"
    exit 1
}

# 获取当前壁纸路径
get_current_wallpaper() {
    # 优先从 pywal 配置获取
    if [ -f "$CURRENT_WALLPAPER_FILE" ]; then
        local wp=$(awk -F'=' '/wallpaper/ {print $2}' "$CURRENT_WALLPAPER_FILE" | head -n 1 | tr -d '"')
        [ -n "$wp" ] && echo "$wp" && return
    fi
    
    # 尝试从常见配置文件获取
    local config_files=(
        "${HOME}/.config/hypr/hyprpaper.conf"
        "${HOME}/.config/noctalia-shell/config.conf"
        "${HOME}/.config/dms-shell/config.conf"
        "${HOME}/.config/sway/config"
    )
    
    for cfg in "${config_files[@]}"; do
        if [ -f "$cfg" ]; then
            local wp=$(grep -i "wallpaper" "$cfg" | head -n 1 | awk '{print $2}')
            [ -n "$wp" ] && echo "$wp" && return
        fi
    done
    
    # 返回默认壁纸
    echo "${WALLPAPER_DIR}/default.jpg"
}

# 应用配色
apply_colors() {
    local wallpaper="$1"
    
    # 防止频繁触发
    local current_time=$(date +%s)
    if [ $((current_time - LAST_TRIGGER_TIME)) -lt 5 ]; then
        return
    fi
    LAST_TRIGGER_TIME=$current_time
    
    info "检测到壁纸变化，应用配色..."
    
    if [ -f "$wallpaper" ]; then
        # 使用 pywal 提取颜色并应用
        if command -v wal &> /dev/null; then
            info "使用 pywal 从壁纸提取颜色..."
            wal -i "$wallpaper" 2>/dev/null
            
            # 更新额外配置
            update_starship
            update_shell_colors
        else
            error "pywal 未安装"
        fi
    else
        error "壁纸文件不存在: $wallpaper"
    fi
}

# 更新 Starship 配置
update_starship() {
    if [ ! -f "${WAL_CACHE}/colors.sh" ]; then
        return
    fi
    
    source "${WAL_CACHE}/colors.sh"
    
    mkdir -p "${HOME}/.config/starship"
    
    cat > "${HOME}/.config/starship/wal.toml" << EOF
[character]
success_symbol = "[➜]($color2)"
error_symbol = "[✗]($color1)"

[git_branch]
symbol = " "
style = "bold $color4"

[git_status]
staged = "[✓]($color2)"
unstaged = "[✗]($color1)"

[directory]
style = "bold $color6"

[package]
style = "bold $color5"
EOF
}

# 更新 Shell 配色
update_shell_colors() {
    if [ ! -f "${WAL_CACHE}/colors.sh" ]; then
        return
    fi
    
    source "${WAL_CACHE}/colors.sh"
    
    # 更新 Noctalia-Shell 配色
    if [ -d "${HOME}/.config/noctalia-shell" ]; then
        cat > "${HOME}/.config/noctalia-shell/colors.conf" << EOF
background=$background
foreground=$foreground
accent=$color2
primary=$color4
secondary=$color5
warning=$color3
error=$color1
EOF
    fi
    
    # 更新 DMS-Shell 配色
    if [ -d "${HOME}/.config/dms-shell" ]; then
        cat > "${HOME}/.config/dms-shell/colors.conf" << EOF
[colors]
background = $background
foreground = $foreground
accent = $color2
primary = $color4
secondary = $color5
warning = $color3
error = $color1
EOF
    fi
}

# 主循环
main() {
    info "启动壁纸变化监听器..."
    
    # 等待文件系统就绪
    sleep 5
    
    # 创建必要目录
    mkdir -p "$WALLPAPER_DIR"
    mkdir -p "$WAL_CACHE"
    
    # 获取初始壁纸
    last_wallpaper=$(get_current_wallpaper)
    last_modified=0
    
    if [ -n "$last_wallpaper" ] && [ -f "$last_wallpaper" ]; then
        last_modified=$(stat -c "%Y" "$last_wallpaper" 2>/dev/null || echo 0)
        info "监控壁纸: $(basename "$last_wallpaper")"
    fi
    
    while true; do
        current_wallpaper=$(get_current_wallpaper)
        
        if [ -n "$current_wallpaper" ] && [ -f "$current_wallpaper" ]; then
            current_modified=$(stat -c "%Y" "$current_wallpaper" 2>/dev/null || echo 0)
            
            # 检查壁纸是否变化（路径变化或文件修改时间变化）
            if [ "$current_wallpaper" != "$last_wallpaper" ] || [ "$current_modified" -ne "$last_modified" ]; then
                info "壁纸变化: $(basename "$last_wallpaper") -> $(basename "$current_wallpaper")"
                apply_colors "$current_wallpaper"
                
                last_wallpaper="$current_wallpaper"
                last_modified="$current_modified"
            fi
        fi
        
        # 额外检查 pywal 缓存目录变化
        if [ -d "$WAL_CACHE" ]; then
            local cache_modified=$(stat -c "%Y" "$WAL_CACHE" 2>/dev/null || echo 0)
            if [ "$cache_modified" -ne "$last_cache_modified" ]; then
                last_cache_modified="$cache_modified"
            fi
        fi
        
        sleep "$WATCH_INTERVAL"
    done
}

main "$@"