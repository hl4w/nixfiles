# Hyprland 窗口管理器 - NixOS 系统级配置模块
#
# 注意: NixOS 26.05 中原生模块为 programs.hyprland（系统级），
#       详细配置（settings/keybinds 等）由 Home Manager 的
#       wayland.windowManager.hyprland 模块管理（见 home/common/hyprland.nix）。
#
# Hyprland 0.55 (NixOS 26.05) 重大变更:
# - 默认配置语言从 hyprlang 切换到 Lua
# - Xwayland 支持从模块独立声明
#
# 参考: https://wiki.nixos.org/wiki/Hyprland
{ pkgs, lib, config, ... }:

{
  # lib.mkIf 放在 config 块内部（而非模块顶层），避免与 desktop.nix 形成
  # 循环依赖：desktop.nix 无条件导入本模块，模块顶层若用 config.desktop.windowManager
  # 做条件判断，会触发 config thunk 求值 → 合并所有模块 config → 又回到这里
  config = lib.mkIf (config.desktop.windowManager == "hyprland") {
    # NixOS 原生 Hyprland 模块（系统级：安装包、桌面会话条目、安全包装等）
    programs.hyprland = {
      enable = true;
      package = pkgs.hyprland;        # 使用 NixOS 库中的 Hyprland 0.55
      xwayland.enable = true;         # 启用 Xwayland 兼容层
      withUWSM = false;               # 不使用 UWSM，直接由 SDDM 启动
    };

    # Hyprland 相关系统包（仅系统级必需的，用户级包在 home/common/apps.nix 中）
    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-hyprland  # Hyprland 桌面门户
      hyprpaper               # Hyprland 壁纸工具
      hyprpicker              # 颜色拾取工具
    ];
  };
}
