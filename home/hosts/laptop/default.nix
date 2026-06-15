{ pkgs, ... }:

{
  # 笔记本特定用户级软件包（网络、电源管理）
  home.packages = with pkgs; [
    # VPN 客户端
    networkmanager-openconnect
    networkmanager-vpnc
    # 电源管理
    powertop
  ];
}