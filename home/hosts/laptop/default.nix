{ pkgs, ... }:

{
  # 笔记本特定用户级软件包（电源管理）
  #
  # NetworkManager VPN 插件已移至 hosts/laptop/configuration.nix 的
  # networking.networkmanager.plugins，因为 NM 守护进程以 root 运行，
  # 只能加载系统级插件，放在 home.packages 中不生效。
  # nmcli/nmtui 随 networking.networkmanager.enable = true 自动安装。
  home.packages = with pkgs; [
    # 电源管理
    powertop
  ];
}