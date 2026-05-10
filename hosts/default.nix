{ config, pkgs, inputs, lib, username,  ... }:

{
  imports = [
    ../modules/bootloader.nix
    ../modules/hardware.nix

    ./hardware-configuration.nix 

    ../modules/flatpak-module.nix
    ../modules/gc.nix
    ../modules/chinese.nix
    ../modules/ai-robot.nix
    #../modules/auto-upgrade.nix
    #../modules/virtualization.nix
    ../modules/hyprland.nix
  ];

  nix.package = pkgs.lix;
  nix.settings = {
    #启用 flakes + nix
    experimental-features = [ "nix-command" "flakes" ];
    # 优先使用国内镜像站，强制覆盖远程缓存
    substituters = lib.mkForce [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
    trusted-substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];

    # 增大下载缓存，防止大文件下载中断 (500MB)
    #download-buffer-size = 524288000;
    connect-timeout = 5;
    fallback = true;
    
    # 自动优化存储，节省空间
    auto-optimise-store = true;
  };

  # 允许非自由软件
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "audio" "render" "libvirtd" "qemu" "kvm" ];
    #shell = pkgs.zsh;
  };

  ### 配置ssh远程登录
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";          # 禁止 root 直接登录（更安全）
    settings.PasswordAuthentication = false;  # 只允许密钥登录，禁用密码
    openFirewall = true;                      # 自动在防火墙放通 22 端口
  };

  #### 全局环境变量 (Wayland 原生)
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
  };

  # 开发别名
  environment.shellAliases = {
    "torch-dev" = "docker run -it --rm --gpus all -v ~/projects:/workspace pytorch/pytorch:latest";
  };

  system.stateVersion = "25.11";
}