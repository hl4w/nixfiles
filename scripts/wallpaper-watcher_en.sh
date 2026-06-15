#!/bin/sh
# shellcheck shell=bash
# Wallpaper change watcher
# Automatically triggers color scheme update when wallpaper file changes

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

# Configuration variables
WALLPAPER_DIR="${HOME}/.wallpapers"
WAL_CACHE="${HOME}/.cache/wal"
CURRENT_WALLPAPER_FILE="${WAL_CACHE}/wal"
WATCH_INTERVAL=2  # Check interval (seconds)
LAST_TRIGGER_TIME=0

info() {
    echo -e "\033[1;34m[WATCHER]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[WATCHER ERROR]\033[0m $1" >&2
}

# Get current wallpaper path
get_current_wallpaper() {
    # Prefer from pywal config
    if [ -f "$CURRENT_WALLPAPER_FILE" ]; then
        local wp=$(awk -F'=' '/wallpaper/ {print $2}' "$CURRENT_WALLPAPER_FILE" | head -n 1 | tr -d '"')
        [ -n "$wp" ] && echo "$wp" && return
    fi
    
    # Try common config files
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
    
    # Return default wallpaper
    echo "${WALLPAPER_DIR}/default.jpg"
}

# Apply colors
apply_colors() {
    local wallpaper="$1"
    
    # Prevent frequent triggers
    local current_time=$(date +%s)
    if [ $((current_time - LAST_TRIGGER_TIME)) -lt 5 ]; then
        return
    fi
    LAST_TRIGGER_TIME=$current_time
    
    info "Wallpaper change detected, applying colors..."
    
    if [ -f "$wallpaper" ]; then
        # Use pywal to extract colors and apply
        if command -v wal &> /dev/null; then
            info "Extracting colors from wallpaper using pywal..."
            wal -i "$wallpaper" 2>/dev/null
            
            # Update extra configs
            update_starship
            update_shell_colors
        else
            error "pywal is not installed"
        fi
    else
        error "Wallpaper file does not exist: $wallpaper"
    fi
}

# Update Starship config
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

# Update Shell colors
update_shell_colors() {
    if [ ! -f "${WAL_CACHE}/colors.sh" ]; then
        return
    fi
    
    source "${WAL_CACHE}/colors.sh"
    
    # Update Noctalia-Shell colors
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
    
    # Update DMS-Shell colors
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

# Main loop
main() {
    info "Starting wallpaper change watcher..."
    
    # Wait for filesystem to be ready
    sleep 5
    
    # Create necessary directories
    mkdir -p "$WALLPAPER_DIR"
    mkdir -p "$WAL_CACHE"
    
    # Get initial wallpaper
    last_wallpaper=$(get_current_wallpaper)
    last_modified=0
    last_cache_modified=0
    
    if [ -n "$last_wallpaper" ] && [ -f "$last_wallpaper" ]; then
        last_modified=$(stat -c "%Y" "$last_wallpaper" 2>/dev/null || echo 0)
        info "Monitoring wallpaper: $(basename "$last_wallpaper")"
    fi
    
    while true; do
        current_wallpaper=$(get_current_wallpaper)
        
        if [ -n "$current_wallpaper" ] && [ -f "$current_wallpaper" ]; then
            current_modified=$(stat -c "%Y" "$current_wallpaper" 2>/dev/null || echo 0)
            
            # Check if wallpaper changed (path changed or file modification time changed)
            if [ "$current_wallpaper" != "$last_wallpaper" ] || [ "$current_modified" -ne "$last_modified" ]; then
                info "Wallpaper changed: $(basename "$last_wallpaper") -> $(basename "$current_wallpaper")"
                apply_colors "$current_wallpaper"
                
                last_wallpaper="$current_wallpaper"
                last_modified="$current_modified"
            fi
        fi
        
        # Extra check for pywal cache directory changes
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
