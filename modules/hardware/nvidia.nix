{ pkgs, lib, ... }:

{
  hardware.nvidia = {
    enable = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    # NixOS 26.05 + NVIDIA 580+ 驱动: kernel suspend notifier 已由模块自动设置，
    # 无需手动添加 boot.kernelParams = [ "nvidia_drm_suspend_notifier=0" ]
  };

  # nvidia-settings 已包含在 nvidia 驱动包中，自动安装
  # 如需单独安装 NVIDIA 工具，可使用 pkgs.nvidia-utils 或 pkgs.nvidiaSettings
}