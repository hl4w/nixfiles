# Noctalia-Shell 配置模块
# 现代化桌面集成 Shell，提供完整的桌面体验
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # ===== 必需依赖 =====
    noctalia-shell         # Noctalia-Shell 主程序
    brightnessctl          # 亮度控制工具
    ffmpeg                 # 多媒体处理
    qt6Packages.qtmultimedia  # Qt6 多媒体支持（NixOS 26.05）
    wlr-randr              # Wayland 显示管理

    # ===== 可选依赖 =====
    cliphist               # 剪贴板历史
    ddcutil                # 外接显示器亮度控制
    power-profiles-daemon  # 电源配置管理
    wlsunset               # 夜间模式（NightLight）
    cava                   # 音频可视化

    # ===== 辅助工具 =====
    libappindicator-gtk3   # GTK 托盘图标支持
    networkmanager-applet  # 网络管理小程序
    blueberry              # 蓝牙管理工具
    pavucontrol            # 音频控制工具
  ];

  # 启用必需的系统服务
  services.dbus.enable = true;                   # D-Bus 通信
  services.power-management.enable = true;       # 电源管理
  services.blueman.enable = true;                # 蓝牙管理
  services.power-profiles-daemon.enable = true;  # 电源配置服务
}