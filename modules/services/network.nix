# 网络配置模块
# NixOS 26.05: networkmanager 选项位于 networking.networkmanager.* 下
# 注意: NetworkManager 自带 DHCP 客户端，启用 NM 时应移除 networking.useDHCP
#       （否则会与 NM 的 DHCP 处理冲突）
{ pkgs, lib, ... }:

{
  networking = {
    networkmanager.enable = true;
    useDHCP = false;               # NetworkManager 管理 DHCP，禁用全局 useDHCP
    firewall = {
      enable = true;
      allowPing = true;
    };
  };

  # NixOS 26.05: DNS 由 systemd-resolved 统一管理
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;
}