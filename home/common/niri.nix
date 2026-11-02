# Niri 窗口管理器 - Home Manager 配置
#
# 使用 Home Manager 的 wayland.windowManager.niri 模块
# 管理 Niri 的详细配置（settings 等）
#
# 系统级配置（安装包、桌面会话）在 modules/desktops/niri.nix
# 通过 programs.niri.enable = true 管理
{ pkgs, ... }:

{
  wayland.windowManager.niri = {
    enable = true;
    package = pkgs.niri;

    settings = {
      gaps = 8;
      border-width = 2;

      font = {
        name = "JetBrainsMono Nerd Font";
        size = 14;
      };

      keybindings = {
        "Super+R" = "spawn rofi -show drun";
        "Super+Return" = "spawn foot";
        "Super+E" = "spawn nemo";
        "Super+B" = "spawn firefox";
        "Super+Q" = "close-window";
        "Super+C" = "spawn codium";
        "Super+P" = "spawn rofi -show powermenu";
        "Super+Shift+Q" = "quit";
      };

      workspace-strip = {
        position = "top";
      };

      xwayland = {
        enable = true;
      };
    };
  };
}
