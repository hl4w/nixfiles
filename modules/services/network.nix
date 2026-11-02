# 网络配置模块
# NixOS 26.05: networkmanager 选项位于 networking.networkmanager.* 下
{ pkgs, lib, ... }:

{
  networking = {
    networkmanager.enable = true;
    useDHCP = true;
    firewall = {
      enable = true;
      allowPing = true;
    };
  };

  # NixOS 26.05: DNS 由 systemd-resolved 统一管理
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;
}