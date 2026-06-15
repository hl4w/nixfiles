# 主机公共配置模块
# 包含所有主机类型共享的基础配置
{ pkgs, ... }:

{
  # 导入公共模块
  imports = [
    ./hardware-common.nix         # 硬件公共配置
    ./desktop-common.nix          # 桌面公共配置
    ../../modules/hardware/mouse.nix    # 鼠标配置（侧键支持）
    ../../modules/boot/default.nix   # 启动配置（UEFI、systemd-boot）
    ../../modules/system/default.nix  # 系统级公共配置
    ../../modules/services/default.nix # 服务配置（网络、安全、虚拟化）
  ];

  # NixOS 状态版本（保持兼容性）
  system.stateVersion = "26.05";

  # 默认用户配置（安装时会替换 youruser）
  users.users.youruser = {
    isNormalUser = true;           # 普通用户
    extraGroups = [ "wheel" "networkmanager" ];  # 附加组：wheel（sudo）、networkmanager
    shell = pkgs.zsh;              # 默认 Shell：Zsh
  };
}