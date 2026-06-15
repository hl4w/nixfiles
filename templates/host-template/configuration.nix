{ pkgs, ... }:

{
  imports = [
    ../common/default.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "<HOSTNAME>";

  # 桌面配置（仅桌面/笔记本使用）
  # desktop = {
  #   windowManager = "hyprland";  # 可选: "hyprland" 或 "niri"
  #   shell = "dms";               # 可选: "dms" 或 "noctalia"
  #   enableInputMethod = true;
  # };
}