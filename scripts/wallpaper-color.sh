#!/bin/sh
# shellcheck shell=bash
# 壁纸取色配色脚本
# 当壁纸更换时自动提取颜色并应用到终端、Shell、编辑器等

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

# ============== 配置变量 ==============
# 用户壁纸目录（Home Manager 会自动从项目复制壁纸到这里）
WALLPAPER_DIR="${HOME}/.wallpapers"
# 默认壁纸文件
DEFAULT_WALLPAPER="default.jpg"
WAL_CACHE="${HOME}/.cache/wal"
COLOR_FILE="${WAL_CACHE}/colors.sh"

# 支持的壁纸格式
SUPPORTED_FORMATS=("jpg" "jpeg" "png" "gif" "webp")

# ============== 颜色名称映射 ==============
COLOR_NAMES=(
    "background"   # 背景色
    "foreground"   # 前景色
    "cursor"       # 光标色
    "color0"       # 黑色
    "color1"       # 红色
    "color2"       # 绿色
    "color3"       # 黄色
    "color4"       # 蓝色
    "color5"       # 紫色
    "color6"       # 青色
    "color7"       # 白色
    "color8"       # 亮黑色
    "color9"       # 亮红色
    "color10"      # 亮绿色
    "color11"      # 亮黄色
    "color12"      # 亮蓝色
    "color13"      # 亮紫色
    "color14"      # 亮青色
    "color15"      # 亮白色
)

# ============== 辅助函数 ==============
info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

success() {
    echo -e "\033[1;32m[OK]\033[0m $1"
}

warning() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
}

# ============== 显示帮助信息 ==============
show_help() {
    echo "壁纸取色配色脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示帮助信息"
    echo "  -w, --wallpaper <path>  指定壁纸路径"
    echo "  -d, --directory     从壁纸目录随机选择"
    echo "  -l, --list          列出可用壁纸"
    echo "  -c, --current       显示当前配色"
    echo "  -a, --apply         应用当前配色（不更换壁纸）"
    echo "  -s, --set <wallpaper>   设置指定壁纸并配色"
    echo ""
    echo "环境变量:"
    echo "  WALLPAPER_DIR   壁纸目录（默认: ~/.wallpapers）"
    echo "  WAL_CACHE       pywal 缓存目录（默认: ~/.cache/wal）"
}

# ============== 列出壁纸 ==============
list_wallpapers() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        error "壁纸目录不存在 - $WALLPAPER_DIR"
        exit 1
    fi
    
    echo "可用壁纸:"
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
    echo "共 $count 张壁纸"
}

# ============== 显示当前配色 ==============
show_current_colors() {
    if [ ! -f "$COLOR_FILE" ]; then
        error "配色文件不存在，请先运行取色"
        exit 1
    fi
    
    echo "当前配色:"
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

# ============== 更新 Starship 配置 ==============
update_starship() {
    [ ! -f "$COLOR_FILE" ] && return
    
    source "$COLOR_FILE"
    
    mkdir -p "${HOME}/.config/starship"
    
    # 创建 starship 配色配置
    cat > "${HOME}/.config/starship/wal.toml" << EOF
# 自动生成的 pywal 配色配置

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

# ============== 更新终端配置 ==============
update_terminal() {
    # 更新 Alacritty 配置
    if [ -f "${HOME}/.config/alacritty/alacritty.toml" ]; then
        wal -t -o alacritty 2>/dev/null || true
    fi
    
    # 更新 Kitty 配置
    if [ -f "${HOME}/.config/kitty/kitty.conf" ]; then
        wal -t -o kitty 2>/dev/null || true
    fi
    
    # 更新 Foot 配置
    if [ -f "${HOME}/.config/foot/foot.ini" ]; then
        wal -t -o foot 2>/dev/null || true
    fi
}

# ============== 更新 Shell 配色（Noctalia-Shell 和 DMS-Shell） ==============
update_shell_colors() {
    [ ! -f "$COLOR_FILE" ] && return
    
    source "$COLOR_FILE"
    
    # 更新 Noctalia-Shell 配色
    if [ -d "${HOME}/.config/noctalia-shell" ]; then
        cat > "${HOME}/.config/noctalia-shell/colors.conf" << EOF
# 自动生成的 pywal 配色
background=$background
foreground=$foreground
accent=$color2
primary=$color4
secondary=$color5
warning=$color3
error=$color1
EOF
        success "Noctalia-Shell 配色已更新"
    fi
    
    # 更新 DMS-Shell 配色
    if [ -d "${HOME}/.config/dms-shell" ]; then
        cat > "${HOME}/.config/dms-shell/colors.conf" << EOF
# 自动生成的 pywal 配色
[colors]
background = $background
foreground = $foreground
accent = $color2
primary = $color4
secondary = $color5
warning = $color3
error = $color1
EOF
        success "DMS-Shell 配色已更新"
    fi
}

# ============== 更新 Neovim 配置 ==============
update_neovim() {
    [ ! -d "${HOME}/.config/nvim" ] && return
    
    source "$COLOR_FILE"
    
    # 创建 Neovim 配色配置
    cat > "${HOME}/.config/nvim/colors/wal.vim" << EOF
" 自动生成的 pywal Neovim 配色
set background=dark

hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "wal"

" 基础颜色
hi Normal guifg=$foreground guibg=$background
hi Cursor guifg=$background guibg=$cursor
hi LineNr guifg=$color8 guibg=$background
hi Comment guifg=$color8 guibg=NONE italic

" 语法高亮
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

" 搜索高亮
hi Search guifg=$background guibg=$color3
hi IncSearch guifg=$background guibg=$color3

" 状态行
hi StatusLine guifg=$foreground guibg=$color8
hi StatusLineNC guifg=$color8 guibg=$color9

" 折叠
hi Folded guifg=$color8 guibg=$color9
hi FoldColumn guifg=$color8 guibg=$background

" 括号匹配
hi MatchParen guifg=$color15 guibg=$color9

" 诊断
hi DiagnosticError guifg=$color1
hi DiagnosticWarn guifg=$color3
hi DiagnosticInfo guifg=$color4
hi DiagnosticHint guifg=$color6
EOF
}

# ============== 设置壁纸 ==============
set_wallpaper() {
    local wallpaper="$1"
    
    # 设置壁纸（通过 Hyprland）
    if command -v hyprctl &> /dev/null; then
        hyprctl hyprpaper wallpaper "eDP-1,$wallpaper"
        success "壁纸已设置 (Hyprland)"
    fi
    
    # 设置壁纸（通过 Noctalia-Shell）
    if command -v noctalia-shell &> /dev/null; then
        noctalia-shell --set-wallpaper "$wallpaper"
        success "壁纸已设置 (Noctalia-Shell)"
    fi
    
    # 设置壁纸（通过 DMS-Shell）
    if command -v dms-shell &> /dev/null; then
        dms-shell --wallpaper "$wallpaper"
        success "壁纸已设置 (DMS-Shell)"
    fi
}

# ============== 应用配色 ==============
apply_colors() {
    if [ ! -f "$COLOR_FILE" ]; then
        error "配色文件不存在，请先运行取色"
        exit 1
    fi
    
    info "应用配色..."
    
    # 重新生成所有配置文件
    wal -R 2>/dev/null
    
    # 更新各个应用配置
    update_starship
    update_terminal
    update_neovim
    update_shell_colors
    
    success "配色已应用！"
}

# ============== 主函数 ==============
main() {
    # 检查 pywal 是否安装
    if ! command -v wal &> /dev/null; then
        error "pywal 未安装，请先安装 pywal"
        error "安装命令: nix-env -iA nixos.pywal"
        exit 1
    fi
    
    local action="apply"
    local wallpaper=""
    
    # 解析命令行参数
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
                error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
    
    # 创建必要的目录
    mkdir -p "$WALLPAPER_DIR"
    mkdir -p "$WAL_CACHE"
    
    # 根据动作执行相应操作
    case "$action" in
        random)
            # 从目录随机选择壁纸
            local wallpapers=()
            for fmt in "${SUPPORTED_FORMATS[@]}"; do
                for file in "$WALLPAPER_DIR"/*."$fmt"; do
                    [ -f "$file" ] && wallpapers+=("$file")
                done
            done
            
            if [ ${#wallpapers[@]} -eq 0 ]; then
                error "壁纸目录中没有找到壁纸文件"
                exit 1
            fi
            
            wallpaper="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
            info "随机选择壁纸: $(basename "$wallpaper")"
            ;;
        
        set)
            if [ -z "$wallpaper" ]; then
                # 使用默认壁纸
                wallpaper="${WALLPAPER_DIR}/${DEFAULT_WALLPAPER}"
                if [ ! -f "$wallpaper" ]; then
                    error "默认壁纸不存在 - $wallpaper"
                    exit 1
                fi
                info "使用默认壁纸: $DEFAULT_WALLPAPER"
            else
                if [ ! -f "$wallpaper" ]; then
                    # 尝试从壁纸目录查找
                    wallpaper="${WALLPAPER_DIR}/${wallpaper}"
                    if [ ! -f "$wallpaper" ]; then
                        error "壁纸不存在 - $wallpaper"
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
    
    # 使用 pywal 提取颜色
    info "从壁纸提取颜色: $(basename "$wallpaper")"
    wal -i "$wallpaper"
    
    # 应用配色
    apply_colors
    
    # 设置壁纸
    set_wallpaper "$wallpaper"
    
    echo ""
    success "完成！配色已根据壁纸自动调整。"
}

# 执行主函数
main "$@"