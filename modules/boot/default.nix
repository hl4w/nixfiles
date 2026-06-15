{ pkgs, lib, ... }:

{
  imports = [
    ./plymouth.nix
  ];

  boot = {
    efi = {
      enable = true;
      canTouchEfiVariables = true;  # 允许 systemd-boot 管理 EFI 变量
    };
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;  # 保留的配置数量
        efiSysMountPoint = "/boot";  # EFI 系统分区挂载点
      };
      timeout = 0;  # 隐藏引导菜单，按任意键可显示
      # 禁用其他引导加载器
      grub.enable = false;
      generic-extlinux-compatible.enable = false;
    };
    # NixOS 26.05 中 boot.initrd.systemd.enable 已成为默认值，无需显式设置
    consoleLogLevel = 3;  # 减少启动日志输出
    initrd.verbose = false;  # 禁用 initrd 详细输出
    kernelParams = [
      "quiet"              # 静默启动
      "splash"             # 启用 splash 屏幕（配合 Plymouth）
      "rd.udev.log_level=3" # 限制 udev 日志级别
      "rd.systemd.show_status=auto"  # 自动显示状态
    ];
  };
}