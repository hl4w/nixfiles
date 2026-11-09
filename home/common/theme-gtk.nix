# GTK 主题配置（Home Manager 用户级）
#
# 纯无条件块，不引用 config —— 避免模块返回值顶层表达式触发
# NixOS modules 框架的 config thunk 循环依赖
#
# 设计原则：
#   GTK 主题是所有图形主机都需要的基础配置，不依赖 WM 模块是否加载
#   所以无条件写入，不做任何 config 条件化判断
#
# 注意：Home Manager 没有 xdg.iconTheme 选项（xdg 模块只管 base
#   directories 和 session variables），图标主题统一由 gtk.iconTheme
#   设置，已包含 Papirus-Dark
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
      package = pkgs.gnome-themes-extra;
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
      package = pkgs.gnome-themes-extra;
    };
  };
}
