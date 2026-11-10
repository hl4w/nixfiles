# Hyprland 窗口配色主题（Home Manager 用户级）
#
# 设计原则：
#   不引用 config，不做任何条件判断
#   - hyprland.nix 已在主机 imports 里排在前面，option 一定存在
#   - Home Manager 模块框架会自动深层合并同名 attrset
#   - 我们只写需要追加的配置，框架 merge 后与 hyprland.nix 的 settings.config 合并
#
# Hyprland 0.55 使用 Lua 配置，所有 hyprlang 的 "节:子节" 选项在 Lua 中都是
# 嵌套表，最终渲染为单次 hl.config({ ... }) 调用。
#
# 必须由已导入 hyprland.nix 的主机显式导入（wayland.windowManager.hyprland HM 模块必须已加载）
{ ... }:

{
  wayland.windowManager.hyprland.settings.config = {
    general = {
      # Hyprland 颜色格式只接受十六进制：rgb(rrggbb) 或 rgba(rrggbbaa)
      col = {
        active_border = "rgb(16c55e)";
        inactive_border = "rgb(475569)";
      };
    };

    decoration = {
      rounding = 12;
      blur = {
        enabled = true;
        size = 3;
        passes = 2;
      };
      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
      };
    };
  };
}
