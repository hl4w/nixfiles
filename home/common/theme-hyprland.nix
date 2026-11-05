# Hyprland 窗口配色主题（Home Manager 用户级）
#
# 必须由已导入 hyprland.nix 的主机显式导入
# （wayland.windowManager.hyprland HM 模块必须已加载，
#  否则 settings 赋值会触发 unmatched definition）
#
# 放在 config 块内部 + lib.mkIf，避免模块返回值顶层表达式引用 config
# 导致 NixOS modules 框架的 config thunk 循环依赖
{ pkgs, config, lib, ... }:

{
  wayland.windowManager.hyprland.settings =
    let
      existingSettings = config.wayland.windowManager.hyprland.settings or {};
      existingDecoration = existingSettings.decoration or {};
    in lib.mkIf (config.wayland.windowManager.hyprland.enable or false) (lib.mkMerge [
      {
        general = {
          col.active_border = "rgba(34, 197, 94)";
          col.inactive_border = "rgba(71, 85, 105)";
        };
      }
      {
        decoration = lib.mkMerge [
          existingDecoration
          {
            rounding = 12;
            blur = true;
            blur_size = 3;
            blur_passes = 2;
            blur_new_windows = true;
            shadow = true;
            shadow_range = 4;
            shadow_render_power = 3;
          }
        ];
      }
    ]);
}
