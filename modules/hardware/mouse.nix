# 鼠标配置模块
# Wayland 环境下的鼠标设置
# 
# 在 Wayland 环境中，鼠标配置由窗口管理器（Hyprland/Niri）直接管理：
# - Hyprland: 在 hyprland.nix 中配置 binds
# - Niri: 在 niri.nix 中配置 mousebindings
#
# 鼠标按钮编号：
# - Button 1: 左键
# - Button 2: 中键（滚轮按下）
# - Button 3: 右键
# - Button 4/5: 滚轮上下滚动
# - Button 6/7: 滚轮倾斜（部分鼠标）
# - Button 8/9: 侧键（后退/前进）
#
# 侧键处理策略：
# - 使用 pass 命令让事件传递给应用程序（如 Nemo、Firefox）
# - 这样可以实现：文件管理器后退/前进、浏览器后退/前进等功能
#
# 调试鼠标按钮（需要手动安装 libinput-tools）：
#   sudo nix-shell -p libinput-tools --run "libinput debug-events --show-keycodes"
{ pkgs, ... }:

{
  # Wayland 环境下无需额外系统级鼠标配置
  # 鼠标侧键处理由窗口管理器（Hyprland/Niri）通过 pass 命令传递给应用程序
}