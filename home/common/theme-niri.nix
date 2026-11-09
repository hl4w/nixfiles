# Niri 窗口管理器配色（占位模块）
#
# 注意: Home Manager release-26.05 没有 wayland.windowManager.niri 模块
#       （modules/services/window-managers/ 目录下无 niri.nix），
#       因此配色不再通过 wayland.windowManager.niri.settings 设置。
#
# Niri 的完整配置（包括配色）已合并到 home/common/niri.nix，
# 通过 xdg.configFile 直接生成 ~/.config/niri/config.kdl（KDL 格式）。
#
# 本文件保留为空模块，仅为兼容 laptop.nix 的 imports 列表，
# 避免 "Path does not exist in Git repository" 错误。
{ ... }:

{
  #  intentionally empty — colors are defined in niri.nix via xdg.configFile
}
