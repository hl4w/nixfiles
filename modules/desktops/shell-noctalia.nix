# Noctalia-Shell 配置模块
# 现代化桌面集成 Shell，提供完整的桌面体验
# 命名说明: nixos-26.05 中 noctalia-shell(v4 legacy) 与 noctalia(v5) 同时存在，
#           上游 v5 不是改名替换，而是全新实现（配置文件不迁移）
{ pkgs, lib, config, ... }:

{
  config = lib.mkIf (config.desktop.shell == "noctalia") {
    environment.systemPackages = with pkgs; [
      # ===== 必需依赖 =====
      # noctalia-shell 4.x 已在包内包装了 brightnessctl / cliphist / ddcutil /
      # wlsunset / wl-clipboard / wlr-randr / imagemagick / bluez 等运行时依赖
      noctalia-shell         # Noctalia-Shell 主程序（v4 legacy，Quickshell 版）

      # ===== 辅助工具 =====
      libayatana-appindicator  # GTK 托盘图标支持（libappindicator-gtk3 已从 nixpkgs 移除）
      networkmanagerapplet     # 网络管理小程序
      pavucontrol              # 音频控制工具
    ];

    # 启用必需的系统服务（依据 Noctalia 官方 NixOS 文档）
    services.dbus.enable = true;                   # D-Bus 通信
    powerManagement.enable = true;                 # 电源管理（挂起/休眠钩子）
    services.blueman.enable = true;                # 蓝牙图形管理
    services.power-profiles-daemon.enable = true;  # 电源配置服务
    services.upower.enable = true;                 # 电量/电源信息（Noctalia 必需）
  };
}
