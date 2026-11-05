# Niri 窗口管理器 - NixOS 系统级配置模块
#
# 注意: NixOS 26.05 中原生模块为 programs.niri（系统级），
#       详细配置（settings 等）由 Home Manager 的
#       wayland.windowManager.niri 模块管理（见 home/common/niri.nix）。
{ pkgs, lib, config, ... }:

{
  config = lib.mkIf (config.desktop.windowManager == "niri") {
    # NixOS 原生 Niri 模块（系统级：安装包、桌面会话条目等）
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    # Niri 相关系统包
    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-wlr  # Wayland 桌面门户
      xwayland                # Xwayland 兼容层
    ];
  };
}
