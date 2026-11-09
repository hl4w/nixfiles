# Niri 窗口配色主题（Home Manager 用户级）
#
# 设计原则：
#   不引用 config，不做任何条件判断
#   - niri.nix 已在主机 imports 里排在前面，option 一定存在
#   - Home Manager 模块框架会自动合并同名 attrset
#   - 我们只写需要追加的配置，框架 merge 后与 niri.nix 的 settings 合并
#
# 必须由已导入 niri.nix 的主机显式导入（wayland.windowManager.niri HM 模块必须已加载）
{ ... }:

{
  wayland.windowManager.niri.settings = {
    border-color = "rgba(34, 197, 94)";
    inactive-border-color = "rgba(71, 85, 105)";

    "workspace-strip" = {
      show-workspace-numbers = true;
      show-window-titles = true;
    };
  };
}
