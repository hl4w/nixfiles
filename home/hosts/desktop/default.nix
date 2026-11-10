{ pkgs, ... }:

{
  # 桌面特定用户级软件包（游戏、视频编辑、创作工具）
  home.packages = with pkgs; [
    # 游戏平台
    #
    # steam 已注释：unfree 包且需从境外 CDN 下载大量运行时（Steam Runtime、
    # 重定向后的 depot），国内网络易超时失败并连带 home-manager-generation 全链失败。
    # 需要时取消注释，或改用 flatpak（flatpak install flathub com.valvesoftware.Steam）。
    # steam
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