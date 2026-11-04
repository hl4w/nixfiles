# DMS-Shell 配置模块（DankMaterialShell）
# NixOS 26.05 官方模块为 programs.dms-shell（nixos/modules/programs/wayland/dms-shell.nix）
# 注意：上游 2.0 已更名为 Dux Shell（包名 dux-shell），但 nixos-26.05 分支仍只提供 dms-shell
{ pkgs, ... }:

{
  programs.dms-shell = {
    enable = true;

    # 模块默认已安装以下可选依赖（无需再手工加入 systemPackages）：
    #   dgop                  - 系统监控组件
    #   glib + networkmanager - VPN 组件
    #   matugen               - 动态取色（enableDynamicTheming）
    #   cava                  - 音频频谱可视化
    #   khal                  - 日历事件
    #   wtype                 - 剪贴板历史直接粘贴

    # 由 systemd 用户服务 dms.service 随 graphical-session.target 自动启动
    systemd.enable = true;
  };

  # DMS 之外仍需要的辅助工具
  environment.systemPackages = with pkgs; [
    wlr-randr                    # Wayland 显示管理工具
    libayatana-appindicator      # GTK 托盘图标支持（libappindicator-gtk3 已从 nixpkgs 移除）
    networkmanagerapplet         # 网络管理小程序
    pavucontrol                  # 音频控制工具
  ];

  # 启用 D-Bus 服务（Shell 通信必需）
  services.dbus.enable = true;
}