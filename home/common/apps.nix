{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    alacritty
    kitty
    foot
    rofi
    nemo                      # Nemo 文件管理器
    nemo-extensions           # Nemo 扩展（支持 PDF/图片预览）
    evince                    # PDF 阅读器（支持预览）
    eog                       # 图片查看器（支持预览）
    firefox
    qutebrowser
    vlc
    gimp
    inkscape
    wps-office-cn
    keepassxc
    nextcloud-client          # Nextcloud 客户端
    vscodium                  # VSCodium 编辑器（开源版 VS Code）
  ];
}