# 网络配置模块
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

  services.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;
}