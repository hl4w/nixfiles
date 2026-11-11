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

    # VMware Workstation 虚拟机支持（open-vm-tools）
    # 提供 vmtoolsd：分辨率自适应、剪贴板共享、拖放、时间同步。
    # GL 链路无需额外配置：内核自带 vmwgfx 模块，
    # hosts/common/hardware-common.nix 的 hardware.graphics.enable = true
    # 提供 Mesa（含 VMware svga Gallium 驱动），Hyprland 可直接走 3D 加速。
    # 前提：宿主机 Workstation 的虚拟机设置 → 显示器 → 勾选 "Accelerate 3D graphics"。
    # 非 VMware 物理机上 vmtoolsd 检测不到 hypervisor 会自行退出，无副作用；
    # 如需精简，可在对应主机的 configuration.nix 中覆盖为 false。
    vmware.guest.enable = lib.mkDefault true;
  };

  # 用户附加组: 使用 users.users.<name>.extraGroups 动态添加，
  # 不硬编码 youruser（会导致 install.sh 替换后仍有残留）
  # 实际组分配在 hosts/common/default.nix 的 users.users.youruser.extraGroups 中处理
}