# 安全配置模块
{ pkgs, lib, ... }:

{
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
    pam.enableSSS = false;
    faillock.enable = true;
  };

  programs.firejail.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 80 443 ];
  };
}