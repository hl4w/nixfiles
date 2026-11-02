{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    alacritty
    kitty
    foot
    rofi
    nemo                      # Nemo 文件管理器
    nemo-extensions           # Nemo 扩展（支持 PDF/图片预览）
    papers                    # GNOME 文档查看器（原 evince，NixOS 26.05 重命名）
    loupe                     # 图片查看器（GNOME 官方继任者，GTK4/Wayland 原生）
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