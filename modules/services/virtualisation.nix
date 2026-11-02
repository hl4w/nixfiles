# 虚拟化配置模块（可选）
# 包含 Docker 和 Libvirt 支持
# 注意：此模块被 common/default.nix 导入，默认对所有主机启用。
# 如不需要 Docker/Libvirt，请在主机级 configuration.nix 中 disable。
{ pkgs, lib, ... }:

{
  virtualisation = {
    docker.enable = true;
    # Libvirt 仅在有虚拟化需求的主机上启用（如 server/desktop）
    # laptop 主机通常不需要，可在 hosts/laptop/configuration.nix 中覆盖
    libvirtd.enable = lib.mkDefault false;
  };

  # 用户附加组: 使用 users.users.<name>.extraGroups 动态添加，
  # 不硬编码 youruser（会导致 install.sh 替换后仍有残留）
  # 实际组分配在 hosts/common/default.nix 的 users.users.youruser.extraGroups 中处理
}