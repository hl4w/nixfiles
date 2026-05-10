{ pkgs, hostname, ... }:

{
  # 开启蓝牙服务
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  # 只要开启了桌面、音频、蓝牙后，会自动开启
  # services.dbus.enable = true;

  # 设置网络配置/防火墙
  networking.hostName = "${hostname}";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # 打印机设置
  services.printing.enable = true;

  # 电源管理设置
  #services.power-profiles-daemon.enable = true; # 笔记本等桌面
  services.tuned.enable = true;  # 电源、CPU、Disk等，主要用在服务器 性能要求高
  services.upower.enable  = true;

  # 音频设置（PipeWire 优于 PulseAudio）
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # 时间区域设置
  time.hardwareClockInLocalTime = true;
  time.timeZone = "Asia/Shanghai";

  # 开启图形加速支持
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # USB自动挂载
  services.gvfs.enable = true;

  virtualisation.vmware.guest.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.bluedevil #blue tooths
    kdePackages.plasma-nm
    
    vulkan-loader vulkan-tools  # 现代版3D加速渲染，与opengl一样，但更现代
  ];
}
