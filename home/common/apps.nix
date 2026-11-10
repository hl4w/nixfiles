{ pkgs, config, ... }:

{
  # qutebrowser 在上游被标记 insecure（"Still accepts eMudhra TLS certs"），
  # 需显式放行才能求值。Home Manager 使用独立的 nixpkgs 实例，因此该放行
  # 必须声明在 HM 模块内，写在系统级 nixpkgs.config 不会生效。
  # 该列表按 "<name>-<version>" 精确匹配，qutebrowser 升级后需同步更新版本号。
  nixpkgs.config.permittedInsecurePackages = [
    "qutebrowser-3.7.0"
  ];

  home.packages = with pkgs; [
    alacritty
    kitty
    foot
    rofi
    nemo                      # Nemo 文件管理器
    evince                    # PDF 阅读器
    loupe                     # 图片查看器（GNOME 官方继任者，GTK4/Wayland 原生）
    firefox
    qutebrowser
    vlc
    gimp
    inkscape
    keepassxc
    nextcloud-client          # Nextcloud 客户端
    vscodium                  # VSCodium 编辑器（开源版 VS Code）
  ];
}