# Niri 窗口配色主题（Home Manager 用户级）
#
# 必须由已导入 niri.nix 的主机显式导入
# （wayland.windowManager.niri HM 模块必须已加载，
#  否则 settings 赋值会触发 unmatched definition）
#
# 放在 config 块内部 + lib.mkIf，避免模块返回值顶层表达式引用 config
# 导致 NixOS modules 框架的 config thunk 循环依赖
{ pkgs, config, lib, ... }:

{
  wayland.windowManager.niri.settings =
    let
      existingSettings = config.wayland.windowManager.niri.settings or {};
      existingStrip = existingSettings."workspace-strip" or {};
    in lib.mkIf (config.wayland.windowManager.niri.enable or false) (lib.mkMerge [
      {
        border-color = "rgba(34, 197, 94)";
        inactive-border-color = "rgba(71, 85, 105)";
      }
      {
        "workspace-strip" = lib.mkMerge [
          existingStrip
          {
            show-workspace-numbers = true;
            show-window-titles = true;
          }
        ];
      }
    ]);
}
