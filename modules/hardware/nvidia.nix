{ pkgs, lib, ... }:

{
  hardware.nvidia = {
    enable = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
  };

  environment.systemPackages = with pkgs; [
    nvidia-settings
  ];
}