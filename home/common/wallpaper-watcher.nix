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

  # 注意: Home Manager 的 systemd.user.services.<name>.enable = true 已由
  #  Install.WantedBy 自动处理，无需额外声明 systemd.user.enable
}