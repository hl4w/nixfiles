# Hyprland 窗口配色主题（Home Manager 用户级）
#
# 设计原则：
#   不引用 config，不做任何条件判断
#   - hyprland.nix 已在主机 imports 里排在前面，option 一定存在
#   - Home Manager 模块框架会自动合并同名 attrset
#   - 我们只写需要追加的配置，框架 merge 后与 hyprland.nix 的 settings 合并
#
# 必须由已导入 hyprland.nix 的主机显式导入（wayland.windowManager.hyprland HM 模块必须已加载）
{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    general = {
      col.active_border = "rgba(34, 197, 94)";
      col.inactive_border = "rgba(71, 85, 105)";
    };

    decoration = {
      rounding = 12;
      blur = true;
      blur_size = 3;
      blur_passes = 2;
      blur_new_windows = true;
      shadow = true;
      shadow_range = 4;
      shadow_render_power = 3;
    };
  };
}
