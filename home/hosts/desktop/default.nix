{ pkgs, ... }:

{
  # 桌面特定用户级软件包（游戏、视频编辑、创作工具）
  home.packages = with pkgs; [
    # 游戏平台
    steam
    lutris
    # 通讯工具
    #
    # discord 已移除：其下载源 stable.dl2.discordapp.net 在国内网络不可达，
    # 导致构建时 curl 超时失败并连带 home-manager-generation 全链失败。
    # 需要时可通过 flatpak 或官方 AppImage 安装。
    #
    # 内容创作
    obs-studio
    blender
  ];
}