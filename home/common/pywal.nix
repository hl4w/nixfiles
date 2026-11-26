# pywal 取色服务（Home Manager 用户级）
#
# 设计:
#   - pywal.service 是 oneshot 服务，登录时执行一次
#   - 优先恢复上次配色（wal -R），失败则从当前壁纸重新提取（wal -i）
#   - 壁纸取色后同步生成 ~/.cache/current_wallpaper.rasi，
#     供 rofi（home/common/rofi/config.rasi）作为背景图变量 @import
#   - wallpaper-watcher.service 通过 Requires/After 依赖本服务，
#     确保壁纸监听启动前已有可用的配色缓存
{ pkgs, config, ... }:

let
  # 整个启动流程集中到一个脚本，避免 ExecStart 中长串 shell 拼接的转义问题
  pywalRestore = pkgs.writeShellScript "pywal-restore" ''
    set -u

    home=${config.home.homeDirectory}
    wal_cache="$home/.cache/wal"
    rofi_wallpaper="$home/.cache/current_wallpaper.rasi"

    # 优先恢复上次配色；无缓存则从当前壁纸提取
    ${pkgs.pywal}/bin/wal -R 2>/dev/null \
      || ${pkgs.pywal}/bin/wal -i "$(head -n 1 "$wal_cache/wal" 2>/dev/null || echo "$home/.wallpapers/default.jpg")" 2>/dev/null \
      || true

    # 生成 rofi 背景图变量文件（rasi 语法，变量需包在选择器块中）：
    #   * { current-image: url("/path/to/wallpaper", height); }
    # rofi 侧用 `background-image: @current-image` 引用
    wp=$(head -n 1 "$wal_cache/wal" 2>/dev/null | tr -d '"' || true)
    if [ -n "$wp" ] && [ -f "$wp" ]; then
      printf '* { current-image: url("%s", height); }\n' "$wp" > "$rofi_wallpaper"
    elif [ ! -f "$rofi_wallpaper" ]; then
      # 兜底：@import 目标必须存在，否则 rofi 会打印 Failed to import
      printf '* { current-image: none; }\n' > "$rofi_wallpaper"
    fi
  '';
in
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

      ExecStart = "${pywalRestore}";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
