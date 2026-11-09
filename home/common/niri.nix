# Niri 窗口管理器 - Home Manager 配置
#
# 注意: Home Manager release-26.05 没有 wayland.windowManager.niri 模块
#       （modules/services/window-managers/ 目录下无 niri.nix）。
#       因此改用 xdg.configFile 直接生成 ~/.config/niri/config.kdl（KDL 格式）。
#
# 系统级配置（安装包、桌面会话）在 modules/desktops/niri.nix
# 通过 programs.niri.enable = true 管理。
#
# 配色（border-color 等）也合并在此文件，因为 KDL 配置是单一文件，
# 不能像 attrset 那样由多个模块自动 merge。
{ pkgs, ... }:

{
  xdg.configFile."niri/config.kdl".text = ''
    // Niri 配置（KDL 格式）
    // 由 home/common/niri.nix 通过 xdg.configFile 生成
    // Home Manager release-26.05 无 wayland.windowManager.niri 模块

    // ===== 布局 =====
    layout {
        gaps 8
        border-width 2
    }

    // ===== 配色 =====
    border-color "rgba(34, 197, 94)"
    inactive-border-color "rgba(71, 85, 105)"

    // ===== 字体 =====
    font {
        family "JetBrainsMono Nerd Font"
        size 14
    }

    // ===== 工作区条 =====
    workspace-strip {
        position top
        show-workspace-numbers
        show-window-titles
    }

    // ===== 快捷键 =====
    binds {
        Mod+Shift+Return { spawn "foot"; }
        Mod+d { spawn "rofi -show drun"; }
        Mod+e { spawn "nemo"; }
        Mod+b { spawn "firefox"; }
        Mod+q { close-window; }
        Mod+c { spawn "codium"; }
        Mod+p { spawn "rofi -show powermenu"; }
        Mod+Shift+q { quit; }
        Mod+Shift+e { power-menu; }
    }
  '';
}
