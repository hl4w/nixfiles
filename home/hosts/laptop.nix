{ pkgs, config, inputs, ... }:

{
  imports = [
    ../common/default.nix
    ../common/input.nix
    ../common/apps.nix
    ../common/theme-gtk.nix          # GTK / XDG 图标主题（基础块，无条件）
    ../common/niri.nix               # 笔记本主机使用 Niri（含配色，KDL 格式）
    ../common/theme-niri.nix         # Niri 配色占位模块（HM 26.05 无 niri 模块，配色已在 niri.nix）
    # 导入笔记本特定用户级配置
    ./laptop/default.nix
  ];
}