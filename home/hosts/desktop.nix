{ pkgs, config, inputs, ... }:

{
  imports = [
    ../common/default.nix
    ../common/input.nix
    ../common/apps.nix
    ../common/unified-theme.nix     # 用户级主题（GTK/XDG/WM配色）
    ../common/hyprland.nix          # 桌面主机使用 Hyprland
    # 导入桌面特定用户级配置
    ./desktop/default.nix
  ];
}