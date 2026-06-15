{ pkgs, lib, ... }:

{
  hardware.firmware = with pkgs; [
    linux-firmware
    sof-firmware
  ];

  hardware.enableRedistributableFirmware = true;
}