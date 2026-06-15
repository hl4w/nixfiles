# DMS-Shell 配置模块
# 轻量级显示管理器 Shell，提供会话选择功能
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dms-shell              # DMS-Shell 主程序
    wlr-randr              # Wayland 显示管理工具
    libappindicator-gtk3   # GTK 托盘图标支持
    networkmanager-applet  # 网络管理小程序
    pavucontrol            # 音频控制工具
  ];

  # 启用 D-Bus 服务（Shell 通信必需）
  services.dbus.enable = true;
}