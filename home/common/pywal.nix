# pywal 取色服务（Home Manager 用户级）
#
# 设计:
#   - pywal.service 是 oneshot 服务，登录时执行一次
#   - 优先恢复上次配色（wal -R），失败则从当前壁纸重新提取（wal -i）
#   - wallpaper-watcher.service 通过 Requires/After 依赖本服务，
#     确保壁纸监听启动前已有可用的配色缓存
{ pkgs, ... }:

{
  systemd.user.services.pywal = {
    Unit = {
      Description = "pywal - Generate color scheme from wallpaper";
      After = [ "graphical-session.target" ];
    };

    Service = {
      # oneshot: 执行一次即退出，配合 RemainAfterExit 保持 active 状态
      # 供 wallpaper-watcher.service 的 Requires 依赖
      Type = "oneshot";
      RemainAfterExit = true;

      # 优先恢复上次配色；若无缓存则从当前壁纸提取
      # %h 是 systemd 用户家目录 specifier
      ExecStart = "${pkgs.bash}/bin/bash -c '"
        + "${pkgs.pywal}/bin/wal -R 2>/dev/null"
        + " || ${pkgs.pywal}/bin/wal -i \"$(head -n 1 %h/.cache/wal/wal 2>/dev/null || echo %h/.wallpapers/default.jpg)\" 2>/dev/null"
        + " || true"
        + "'";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
