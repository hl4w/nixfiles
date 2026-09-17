{ pkgs, ... }:

{
  imports = [
    ../common/default.nix
    ./hardware-configuration.nix
    ../../modules/desktops/desktop.nix
    ../../modules/hardware/bluetooth.nix
  ];

  networking.hostName = "laptop";

  # NetworkManager VPN 插件（NixOS 26.05: 原 packages 已重命名为 plugins）
  # 必须在系统级声明，NM 守护进程以 root 运行，只能加载系统级插件
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openconnect   # Cisco AnyConnect VPN
    networkmanager-vpnc          # Cisco IPsec VPN
    networkmanager-openvpn       # OpenVPN（最常见的 VPN 协议）
  ];

  # 笔记本 WiFi 省电（NixOS 26.05 官方推荐）
  networking.networkmanager.wifi.powersave = true;

  # 笔记本电源管理
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };
}