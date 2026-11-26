# Rofi 启动器与电源菜单
#
# 参考 gitea-nixfiles25 的 home/rofi：
#   - 原实现用 home.activation 里的 `cp -rf configs/* ~/.config/rofi/`（命令式拷贝，
#     不参与 Nix 求值、不可回滚），这里改为 xdg.configFile 声明式管理；
#   - 主题源文件保留在 home/common/rofi/config.rasi，可直接编辑后 rebuild 生效。
{ pkgs, ... }:

let
  # 电源菜单。
  # rofi 没有内置 powermenu mode，`rofi -show powermenu` 会报
  # "Mode powermenu is not found"（原 hyprland.nix 的绑定即存在该问题）。
  # 这里用 -dmenu 列出选项，选中后执行对应动作。
  # 注：仓库未配置锁屏程序（hyprlock/swaylock），因此不提供「锁屏」项。
  powermenu = pkgs.writeShellScriptBin "powermenu" ''
    set -eu

    entries=$'注销\n重启\n关机'

    chosen=$(printf '%s\n' "$entries" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "电源" -no-custom) || exit 0

    case "$chosen" in
      注销) loginctl terminate-user "$USER" ;;
      重启) systemctl reboot ;;
      关机) systemctl poweroff ;;
    esac
  '';
in
{
  # rofi 默认读取 $XDG_CONFIG_HOME/rofi/config.rasi
  xdg.configFile."rofi/config.rasi".source = ./rofi/config.rasi;

  home.packages = [ powermenu ];
}
