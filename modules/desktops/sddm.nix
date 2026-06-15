# SDDM 显示管理器配置模块
# Simple Desktop Display Manager - 现代化 Qt 显示管理器
# 仅支持 Wayland 显示服务器，使用 Xwayland 兼容 X 应用
#
# 注意：此文件专门用于 SDDM 配置
# 未来如需添加其他显示管理器（如 LightDM、GDM），请创建独立模块：
# - lightdm.nix
# - gdm.nix
#
# 主题配置由 unified-theme.nix 统一管理
{ pkgs, lib, config, ... }:

let
  cfg = config.desktop;
in
{
  # 禁用完整的 X11 服务器（使用 Xwayland 兼容 X 应用）
  services.xserver.enable = false;

  # 启用显示管理器
  services.display-manager = {
    enable = true;
    # 默认会话根据窗口管理器选择动态设置
    defaultSession = lib.mkDefault (
      if cfg.windowManager == "hyprland" then "hyprland"
      else if cfg.windowManager == "niri" then "niri"
      else "hyprland"
    );
  };

  # SDDM 配置 - Simple Desktop Display Manager
  services.sddm = {
    enable = true;                 # 启用 SDDM
    wayland.enable = true;         # 启用 Wayland 支持
    displayServer = "wayland";     # 使用 Wayland 显示服务器
    package = pkgs.kdePackages.sddm;  # 使用 Qt6 版本的 SDDM（NixOS 26.05）
    theme = "breeze";              # Breeze 主题（与统一主题风格一致）
  };

  # SDDM Breeze 主题依赖包
  # NixOS 26.05 中 Breeze 主题需要以下 KDE 包支持
  environment.systemPackages = with pkgs.kdePackages; [
    breeze              # Breeze 视觉风格
    breeze-icons        # Breeze 图标主题
    kirigami            # KDE QML 框架（主题依赖）
    libplasma           # Plasma 库（主题依赖）
    plasma5support      # Plasma 5 兼容支持
    qtsvg               # Qt SVG 支持
    qtvirtualkeyboard   # 虚拟键盘支持
  ];
}