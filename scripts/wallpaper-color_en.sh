#!/bin/sh
# Author: Silas Zhang (2026)
# shellcheck shell=bash
# Wallpaper color extraction script
# Automatically extracts colors from wallpaper and applies to terminal, shell, editor, etc.

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

# ============== Configuration Variables ==============
# User wallpaper directory (Home Manager will automatically copy wallpapers here)
WALLPAPER_DIR="${HOME}/.wallpapers"
# Default wallpaper file
DEFAULT_WALLPAPER="default.jpg"
WAL_CACHE="${HOME}/.cache/wal"
COLOR_FILE="${WAL_CACHE}/colors.sh"

# Supported wallpaper formats
SUPPORTED_FORMATS=("jpg" "jpeg" "png" "gif" "webp")

# ============== Color Name Mapping ==============
COLOR_NAMES=(
    "background"   # Background color
    "foreground"  # Foreground color
    "cursor"      # Cursor color
    "color0"      # Black
    "color1"      # Red
    "color2"      # Green
    "color3"      # Yellow
    "color4"      # Blue
    "color5"      # Purple
    "color6"      # Cyan
    "color7"      # White
    "color8"      # Bright black
    "color9"      # Bright red
    "color10"     # Bright green
    "color11"     # Bright yellow
    "color12"     # Bright blue
    "color13"     # Bright purple
    "color14"     # Bright cyan
    "color15"     # Bright white
)

# ============== Helper Functions ==============
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# ============== Show Help ==============
show_help() {
    echo "Wallpaper Color Extraction Script"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -w, --wallpaper <path>  Specify wallpaper path"
    echo "  -d, --directory     Randomly select from wallpaper directory"
    echo "  -l, --list          List available wallpapers"
    echo "  -c, --current       Show current color scheme"
    echo "  -a, --apply         Apply current color scheme (without changing wallpaper)"
    echo "  -s, --set <wallpaper>   Set specified wallpaper and apply colors"
    echo ""
    echo "Environment Variables:"
    echo "  WALLPAPER_DIR   Wallpaper directory (default: ~/.wallpapers)"
    echo "  WAL_CACHE       pywal cache directory (default: ~/.cache/wal)"
}

# ============== List Wallpapers ==============
list_wallpapers() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        error "Wallpaper directory does not exist - $WALLPAPER_DIR"
        exit 1
    fi
    
    echo "Available wallpapers:"
    echo "------------------------"
    
    local format_pattern=""
    for fmt in "${SUPPORTED_FORMATS[@]}"; do
        [ -n "$format_pattern" ] && format_pattern="$format_pattern -o "
        format_pattern="$format_pattern -name \"*.$fmt\""
    done
    
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( $format_pattern \) | \
        sort | \
        while read -r file; do
            local basename=$(basename "$file")
            local size=$(du -h "$file" | cut -f1)
            printf "  %-30s %s\n" "$basename" "$size"
        done
    
    local count=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( $format_pattern \) | wc -l)
    echo "------------------------"
    echo "Total: $count wallpapers"
}

# ============== Show Current Colors ==============
show_current_colors() {
    if [ ! -f "$COLOR_FILE" ]; then
        error "Color file does not exist, please run color extraction first"
        exit 1
    fi
    
    echo "Current colors:"
    echo "------------------------"
    source "$COLOR_FILE"
    
    local i=0
    for color_name in "${COLOR_NAMES[@]}"; do
        local var_name="$color_name"
        if [ $i -gt 2 ]; then
            var_name="color$((i-3))"
        fi
        local color_value="${!var_name}"
        printf "  %-12s %s\n" "$color_name:" "$color_value"
        i=$((i + 1))
    done
}

# ============== Update Starship Config ==============
update_starship() {
    [ ! -f "$COLOR_FILE" ] && return
    
    source "$COLOR_FILE"
    
    mkdir -p "${HOME}/.config/starship"
    
    # Create starship color config
    cat > "${HOME}/.config/starship/wal.toml" << EOF
# Auto-generated pywal color config

[character]
success_symbol = "[➜]($color2)"
error_symbol = "[✗]($color1)"

[git_branch]
symbol = " "
style = "bold $color4"

[git_status]
ahead = "⇡"
behind = "⇣"
conflicted = "⚔"
deleted = "✗"
renamed = "➜"
staged = "[✓]($color2)"
unmerged = "═"
unstaged = "[✗]($color1)"
untracked = "?"

[directory]
style = "bold $color6"

[package]
style = "bold $color5"

[nodejs]
style = "bold $color3"

[python]
style = "bold $color3"

[rust]
style = "bold $color6"

[nix_shell]
style = "bold $color5"

[cmd_duration]
style = "bold $color2"

[exit_code]
style = "bold $color1"
EOF
}

# ============== Update Terminal Config ==============
update_terminal() {
    # Update Alacritty config
    if [ -f "${HOME}/.config/alacritty/alacritty.toml" ]; then
        wal -t -o alacritty 2>/dev/null || true
    fi
    
    # Update Kitty config
    if [ -f "${HOME}/.config/kitty/kitty.conf" ]; then
        wal -t -o kitty 2>/dev/null || true
    fi
    
    # Update Foot config
    if [ -f "${HOME}/.config/foot/foot.ini" ]; then
        wal -t -o foot 2>/dev/null || true
    fi
}

# ============== Update Shell Colors (Noctalia-Shell and DMS-Shell) ==============
update_shell_colors() {
    [ ! -f "$COLOR_FILE" ] && return
    
    source "$COLOR_FILE"
    
    # Update Noctalia-Shell colors
    if [ -d "${HOME}/.config/noctalia-shell" ]; then
        cat > "${HOME}/.config/noctalia-shell/colors.conf" << EOF
# Auto-generated pywal colors
background=$background
foreground=$foreground
accent=$color2
primary=$color4
secondary=$color5
warning=$color3
error=$color1
EOF
        success "Noctalia-Shell colors updated"
    fi
    
    # Update DMS-Shell colors
    if [ -d "${HOME}/.config/dms-shell" ]; then
        cat > "${HOME}/.config/dms-shell/colors.conf" << EOF
# Auto-generated pywal colors
[colors]
background = $background
foreground = $foreground
accent = $color2
primary = $color4
secondary = $color5
warning = $color3
error = $color1
EOF
        success "DMS-Shell colors updated"
    fi
}

# ============== Update Neovim Config ==============
update_neovim() {
    [ ! -d "${HOME}/.config/nvim" ] && return
    
    source "$COLOR_FILE"
    
    # Create Neovim color config
    cat > "${HOME}/.config/nvim/colors/wal.vim" << EOF
" Auto-generated pywal Neovim colors
set background=dark

hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "wal"

" Basic colors
hi Normal guifg=$foreground guibg=$background
hi Cursor guifg=$background guibg=$cursor
hi LineNr guifg=$color8 guibg=$background
hi Comment guifg=$color8 guibg=NONE italic

" Syntax highlighting
hi Constant guifg=$color11
hi String guifg=$color11
hi Character guifg=$color11
hi Number guifg=$color11
hi Boolean guifg=$color11
hi Float guifg=$color11

hi Identifier guifg=$color7
hi Function guifg=$color4
hi Statement guifg=$color5
hi Keyword guifg=$color5
hi Operator guifg=$color5
hi Exception guifg=$color5

hi PreProc guifg=$color6
hi Include guifg=$color6
hi Define guifg=$color6
hi Macro guifg=$color6
hi PreCondit guifg=$color6

hi Type guifg=$color3
hi StorageClass guifg=$color3
hi Structure guifg=$color3
hi Typedef guifg=$color3

hi Special guifg=$color13
hi SpecialChar guifg=$color13
hi Tag guifg=$color13
hi Delimiter guifg=$color8
hi SpecialComment guifg=$color8
hi Debug guifg=$color1

" Search highlighting
hi Search guifg=$background guibg=$color3
hi IncSearch guifg=$background guibg=$color3

" Status line
hi StatusLine guifg=$foreground guibg=$color8
hi StatusLineNC guifg=$color8 guibg=$color9

" Folding
hi Folded guifg=$color8 guibg=$color9
hi FoldColumn guifg=$color8 guibg=$background

" Parenthesis matching
hi MatchParen guifg=$color15 guibg=$color9

" Diagnostics
hi DiagnosticError guifg=$color1
hi DiagnosticWarn guifg=$color3
hi DiagnosticInfo guifg=$color4
hi DiagnosticHint guifg=$color6
EOF
}

# ============== Set Wallpaper ==============
set_wallpaper() {
    local wallpaper="$1"
    
    # Set wallpaper (via Hyprland)
    if command -v hyprctl &> /dev/null; then
        hyprctl hyprpaper wallpaper "eDP-1,$wallpaper"
        success "Wallpaper set (Hyprland)"
    fi
    
    # Set wallpaper (via Noctalia-Shell)
    if command -v noctalia-shell &> /dev/null; then
        noctalia-shell --set-wallpaper "$wallpaper"
        success "Wallpaper set (Noctalia-Shell)"
    fi
    
    # Set wallpaper (via DMS-Shell)
    if command -v dms-shell &> /dev/null; then
        dms-shell --wallpaper "$wallpaper"
        success "Wallpaper set (DMS-Shell)"
    fi
}

# ============== Apply Colors ==============
apply_colors() {
    if [ ! -f "$COLOR_FILE" ]; then
        error "Color file does not exist, please run color extraction first"
        exit 1
    fi
    
    info "Applying colors..."
    
    # Regenerate all config files
    wal -R 2>/dev/null
    
    # Update various app configs
    update_starship
    update_terminal
    update_neovim
    update_shell_colors
    
    success "Colors applied!"
}

# ============== Main Function ==============
main() {
    # Check if pywal is installed
    if ! command -v wal &> /dev/null; then
        error "pywal is not installed, please install pywal first"
        error "Install command: nix-env -iA nixos.pywal"
        exit 1
    fi
    
    local action="apply"
    local wallpaper=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -w|--wallpaper)
                wallpaper="$2"
                action="set"
                shift
                ;;
            -d|--directory)
                action="random"
                ;;
            -l|--list)
                list_wallpapers
                exit 0
                ;;
            -c|--current)
                show_current_colors
                exit 0
                ;;
            -a|--apply)
                action="apply"
                ;;
            -s|--set)
                wallpaper="$2"
                action="set"
                shift
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
    
    # Create necessary directories
    mkdir -p "$WALLPAPER_DIR"
    mkdir -p "$WAL_CACHE"
    
    # Execute corresponding action
    case "$action" in
        random)
            # Randomly select wallpaper from directory
            local wallpapers=()
            for fmt in "${SUPPORTED_FORMATS[@]}"; do
                for file in "$WALLPAPER_DIR"/*."$fmt"; do
                    [ -f "$file" ] && wallpapers+=("$file")
                done
            done
            
            if [ ${#wallpapers[@]} -eq 0 ]; then
                error "No wallpaper files found in wallpaper directory"
                exit 1
            fi
            
            wallpaper="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
            info "Randomly selected wallpaper: $(basename "$wallpaper")"
            ;;
        
        set)
            if [ -z "$wallpaper" ]; then
                # Use default wallpaper
                wallpaper="${WALLPAPER_DIR}/${DEFAULT_WALLPAPER}"
                if [ ! -f "$wallpaper" ]; then
                    error "Default wallpaper does not exist - $wallpaper"
                    exit 1
                fi
                info "Using default wallpaper: $DEFAULT_WALLPAPER"
            else
                if [ ! -f "$wallpaper" ]; then
                    # Try to find in wallpaper directory
                    wallpaper="${WALLPAPER_DIR}/${wallpaper}"
                    if [ ! -f "$wallpaper" ]; then
                        error "Wallpaper does not exist - $wallpaper"
                        exit 1
                    fi
                fi
            fi
            ;;
        
        apply)
            apply_colors
            exit 0
            ;;
    esac
    
    # Use pywal to extract colors
    info "Extracting colors from wallpaper: $(basename "$wallpaper")"
    wal -i "$wallpaper"
    
    # Apply colors
    apply_colors
    
    # Set wallpaper
    set_wallpaper "$wallpaper"
}

main "$@"
