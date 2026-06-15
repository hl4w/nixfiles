{ pkgs, ... }:

{
  imports = [
    ../common/default.nix
    ./hardware-configuration.nix
    ../../modules/desktops/desktop.nix
  ];

  networking.hostName = "desktop";
}