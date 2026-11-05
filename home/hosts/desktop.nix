{ pkgs, config, inputs, ... }:

{
  imports = [
    ../common/default.nix
    ../common/input.nix
    ../common/apps.nix
    ../common/theme-gtk.nix          # GTK / XDG 图标主题（基础块，无条件）
    ../common/hyprland.nix           # 桌面主机使用 Hyprland
    ../common/theme-hyprland.nix     # Hyprland 窗口配色（需 hyprland 模块已加载）
    # 导入桌面特定用户级配置
    ./desktop/default.nix
  ];
}