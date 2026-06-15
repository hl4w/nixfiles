{ pkgs, ... }:

{
  # 桌面特定用户级软件包（游戏、视频编辑、创作工具）
  home.packages = with pkgs; [
    # 游戏平台
    steam
    lutris
    # 通讯工具
    discord
    # 内容创作
    obs-studio
    blender
    kdenlive
  ];
}