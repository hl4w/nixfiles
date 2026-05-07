{ config, pkgs, lib, ... }:

{
  # 设置系统的中文环境
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
    
    extraLocaleSettings = {
      LC_TIME = "en_US.UTF-8";       # 日期显示为中文（如 2026-04-21 星期二）
      LC_MONETARY = "zh_CN.UTF-8";   # 货币符号用人民币格式
      LC_NUMERIC = "zh_CN.UTF-8";    # 数字格式用中文习惯
    };
  };

  # 启用 fcitx5 输入法框架（系统级）
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5
      kdePackages.fcitx5-qt
      kdePackages.fcitx5-configtool

      fcitx5-rime
      fcitx5-nord                       
      fcitx5-pinyin-zhwiki             
      fcitx5-lua 
      librime
      rime-ice     
    ];
    fcitx5.waylandFrontend = true;
  };


  environment.sessionVariables = {
    #GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    INPUT_METHOD = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";

    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "hyprland"; 
  };

  ## 中文字体优化
  fonts.packages = with pkgs; [
    jetbrains-mono
    dejavu_fonts
    noto-fonts 
    noto-fonts-cjk-sans    # 思源黑体
    noto-fonts-cjk-serif   # 思源宋体
    noto-fonts-color-emoji
    source-han-sans        # 思源黑体
    nerd-fonts.jetbrains-mono

    fira-code               # 等宽
    liberastika
    source-code-pro
    wqy_microhei
    font-awesome
    iosevka
  ];

  environment.systemPackages = with pkgs; [
    nuspell
    hyphen
    hunspell
    hunspellDicts.en_US
  ];

}
