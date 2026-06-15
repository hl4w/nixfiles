# 虚拟化配置模块（可选）
# 包含 Docker 和 Libvirt 支持
{ pkgs, lib, ... }:

{
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  users.users.youruser.extraGroups = [ "docker" "libvirt" ];
}