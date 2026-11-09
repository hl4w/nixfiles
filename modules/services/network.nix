# 网络配置模块
# NixOS 26.05: networkmanager 选项位于 networking.networkmanager.* 下
# 注意: networkmanager.enable = true 会自动将 networking.useDHCP 设为 false
# （NetworkManager 自己管理 DHCP），不要再手动设置 useDHCP
{ pkgs, lib, ... }:

{
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
    };
  };

  # NixOS 26.05: DNS 由 systemd-resolved 统一管理
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;
}