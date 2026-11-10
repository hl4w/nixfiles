# 壁纸变化监听服务
{ pkgs, ... }:

{
  # 创建壁纸监听器脚本
  home.file.".config/wallpaper-watcher/wallpaper-watcher.sh" = {
    source = ./../../scripts/wallpaper-watcher.sh;
    executable = true;
  };

  # 启动壁纸监听服务（systemd user service）
  systemd.user.services.wallpaper-watcher = {
    Unit = {
      Description = "Wallpaper change watcher";
      After = [ "graphical-session.target" ];
      # 注意: 之前写了 Requires = [ "pywal.service" ]，但仓库里从未定义
      # pywal.service（既无 services.pywal.enable，也无 systemd.user.services.pywal），
      # 导致 wallpaper-watcher.service 启动时 systemd 报
      # "Unit pywal.service not found"。pywal 仅作为系统包安装
      # （modules/desktops/unified-theme.nix 的 home.packages），
      # 并不提供同名 systemd service，因此移除该依赖。
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash %h/.config/wallpaper-watcher/wallpaper-watcher.sh";
      Restart = "on-failure";
      RestartSec = "5";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # 注意: Home Manager 的 systemd.user.services.<name>.enable = true 已由
  #  Install.WantedBy 自动处理，无需额外声明 systemd.user.enable
}