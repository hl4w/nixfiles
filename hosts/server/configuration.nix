{ pkgs, ... }:

{
  imports = [
    ../common/default.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "server";

  services.openssh.enable = true;
}