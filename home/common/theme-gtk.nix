# GTK / XDG 图标主题配置（Home Manager 用户级）
#
# 纯无条件块，不引用 config —— 避免模块返回值顶层表达式触发
# NixOS modules 框架的 config thunk 循环依赖
#
# 设计原则：
#   GTK/XDG 是所有图形主机都需要的基础主题，不依赖 WM 模块是否加载
#   所以无条件写入，不做任何 config 条件化判断
#
# HM 26.05+: gtk.gtk4.theme 不再默认镜像 gtk.theme，需显式设置
# WM 特定主题配色在 theme-hyprland.nix / theme-niri.nix，由主机 imports 决定
{ pkgs, ... }:

{
  # ==================== GTK 主题配置 ====================
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Noto Sans";
      size = 11;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-decoration-layout = "menu:minimize,maximize,close";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    # HM 26.05+: gtk4.theme 不再默认镜像 gtk.theme，必须显式设置
    gtk4.theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
  };

  # ==================== XDG 图标主题 ====================
  xdg.iconTheme = {
    enable = true;
    name = "Papirus-Dark";
  };
}
