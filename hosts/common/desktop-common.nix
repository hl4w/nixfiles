# 桌面公共配置
# 包含所有桌面主机共享的基础配置
# 
# 架构说明：
# - desktop.nix 模块提供桌面选项的默认值（windowManager, shell, polkitAgent）
# - install.sh 在安装时根据用户选择生成主机级别的 desktop 配置
# - 此文件只包含不依赖于具体桌面选项的通用配置
{ pkgs, ... }:

{
  # 桌面环境通用配置（不依赖具体桌面选项）
  
  # 用户附加组（桌面环境需要的权限）
  users.users.youruser.extraGroups = [ "video" "audio" ];
}