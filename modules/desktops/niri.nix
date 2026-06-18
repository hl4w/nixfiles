# Niri 窗口管理器配置模块
# 现代化平铺式 Wayland 窗口管理器，适合笔记本使用
# 使用 NixOS 26.05 官方库中的 niri 包
# 主题配色由 unified-theme.nix 统一管理
{ config, pkgs, ... }:

{
  # 导入统一主题配置（包含 Niri 主题配色）
  imports = [
    ./unified-theme.nix  # 统一主题配置（GTK、Qt、Hyprland、Niri、Shell 主题）
  ];

  # Niri 窗口管理器配置
  wayland.windowManager.niri = {
    enable = true;  # 启用 Niri
    # 使用 NixOS 26.05 官方库中的 niri 包
    package = pkgs.niri;

    # Niri 设置（主题配色由 unified-theme.nix 统一管理）
    settings = {
      gaps = 8;                              # 窗口间距
      border-width = 2;                      # 边框宽度
      # border-color 和 inactive-border-color 由 unified-theme.nix 管理

      # 字体设置
      font = {
        name = "JetBrainsMono Nerd Font";  # 字体名称
        size = 14;                          # 字体大小
      };

      # 键盘快捷键
      keybindings = {
        "Super+R" = "spawn rofi -show drun";  # 打开应用启动器
        "Super+Return" = "spawn foot";      # 打开终端（foot）
        "Super+E" = "spawn nemo";           # 打开文件管理器
        "Super+B" = "spawn firefox";        # 打开 Firefox 浏览器
        "Super+Q" = "close-window";         # 关闭窗口
        "Super+C" = "spawn code";           # 打开 VS Code
        "Super+P" = "spawn rofi -show powermenu"; # 打开电源菜单
        "Super+Shift+Q" = "quit";           # 退出 Niri
      };

      # 鼠标侧键不绑定到窗口管理器，让应用程序（如 Nemo）自行处理后退/前进
      # mousebindings = {};

      # 工作区条设置（show-workspace-numbers/show-window-titles 由 unified-theme.nix 管理）
      workspace-strip = {
        position = "top";                   # 位置：顶部
      };

      # Xwayland 兼容设置
      xwayland = {
        enable = true;                      # 启用 Xwayland 支持
      };
    };
  };

  # Niri 相关系统包（仅系统级必需的，用户级包在 home/common/apps.nix 中）
  # polkit 代理由 desktop.nix 根据配置选择（polkit-kde-agent-1 或 hyprpolkitagent）
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-wlr  # Wayland 桌面门户
    xwayland                # Xwayland 兼容层
  ];
}