# 固件配置模块
# NixOS 26.05: hardware.firmware 显式列出需要的固件包
# 注意: hardware.enableRedistributableFirmware 是历史遗留选项，
#       当显式设置 hardware.firmware 时无需再启用此选项
{ pkgs, lib, ... }:

{
  hardware.firmware = with pkgs; [
    linux-firmware    # Linux 官方固件集合
    sof-firmware      # Sound Open Firmware（音频 DSP 固件）
  ];
}