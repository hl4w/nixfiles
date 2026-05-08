# ~/nix-config/home.nix
{ config, pkgs, inputs,  ... }:

{
  home.packages = with pkgs; [
      # ==============================
    # 开发工具 & 编程环境
    # ==============================
    vscodium  wtype  emacs-nox devenv  bazel 
 
    kdePackages.kate
    #obsidian

    lazygit git-ignore  gitleaks

    hugo  glow  ripgrep pandoc  highlight graphviz

    # ==============================
    # 终端 & Shell 工具
    # ==============================
    oh-my-zsh zsh-completions zsh-autocomplete  zsh-powerlevel10k zsh-clipboard zsh-syntax-highlighting

    foot  tmux  starship

    fastfetch btop  bat eza fzf figlet  gum

    # ==============================
    # 文件管理 & 压缩 & 预览
    # ==============================
    lf  ranger  yazi

    kdePackages.ark
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.kio-extras
    kdePackages.kio-fuse
    kdePackages.kimageformats
    kdePackages.kdegraphics-thumbnailers

    nemo  nemo-python nemo-preview  nemo-fileroller nemo-seahorse

    zip unzip unrar
    qalculate-qt

    # ==============================
    # 文档阅读 & 图片查看
    # ==============================
    kdePackages.okular
    kdePackages.gwenview

    # ==============================
    # 多媒体 & 影音
    # ==============================
    mpv mpv-handler
    vlc ffmpegthumbnailer
    kdePackages.elisa

    # ==============================
    # 远程 & 网络
    # ==============================
    kdePackages.krdc
    mosh  impala  ethtool

    # ==============================
    # 云同步
    # ==============================
    nextcloud-client

    # ==============================
    # 系统工具 & 硬件 & 监控
    # ==============================
    brightnessctl
    clamav
    usbutils  pciutils  psi-notify  poweralertd

    # ==============================
    # 主题 & 光标 & 图标 & Qt 支持
    # ==============================
    kdePackages.qtsvg

    catppuccin-kvantum
    catppuccin-cursors
    bibata-cursors

    numix-icon-theme-circle
    colloid-icon-theme
    adwaita-icon-theme
    papirus-icon-theme
  ];

  programs.direnv = {
    enable = true; #自动加载环境变量
    enableBashIntegration = true;
    enableZshIntegration = true;
  };



}