# 壁纸变化监听服务
{ pkgs, ... }:

{
  # 创建壁纸监听器脚本
  home.file.".config/wallpaper-watcher/wallpaper-watcher.sh" = {
    source = ./../../scripts/wallpaper-watcher.sh;
    executable = true;
  };

  # 启动壁纸监听服务
  systemd.user.services.wallpaper-watcher = {
    Unit = {
      Description = "Wallpaper change watcher";
      After = [ "graphical-session.target" "pywal.service" ];
      Requires = [ "pywal.service" ];
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

  # 确保服务自动启动
  systemd.user.enable = true;
  systemd.user.services.wallpaper-watcher.enable = true;
}