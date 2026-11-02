{ pkgs, config, inputs, ... }:

{
  imports = [
    ../common/default.nix
    ../common/input.nix
    ../common/apps.nix
    ../common/unified-theme.nix     # 用户级主题（GTK/XDG/WM配色）
    ../common/niri.nix              # 笔记本主机使用 Niri
    # 导入笔记本特定用户级配置
    ./laptop/default.nix
  ];
}