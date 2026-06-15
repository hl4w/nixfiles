{ pkgs, ... }:

{
  imports = [
    ../common/default.nix
    ./hardware-configuration.nix
    ../../modules/desktops/desktop.nix
    ../../modules/hardware/bluetooth.nix
  ];

  networking.hostName = "laptop";

  # 笔记本电源管理
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };
}