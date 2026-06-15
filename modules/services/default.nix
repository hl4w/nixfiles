# 服务模块入口
{ pkgs, lib, ... }:

{
  imports = [
    ./network.nix
    ./security.nix
    ./virtualisation.nix
  ];
}