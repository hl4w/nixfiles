# 统一主题配置（Home Manager 用户级）
#
# 提供 GTK 主题、XDG 图标主题、Hyprland/Niri 窗口配色等用户级主题配置
#
# 注意:
# - gtk、xdg.iconTheme、wayland.windowManager.* 是 Home Manager 选项
# - NixOS 系统级主题（Qt、SDDM、环境变量）在 modules/desktops/unified-theme.nix
# - HM 26.05+: gtk.gtk4.theme 不再默认镜像 gtk.theme，需显式设置
# - 不要在模块 function 顶层表达式里引用 config：会触发 NixOS/HM 的模块循环
#   依赖（desktop.nix 的子模块就是反例）。把条件化逻辑内联到 option 值内部。
{ pkgs, config, lib, ... }:

{
  # ==================== GTK 主题配置（无条件生效） ====================
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

  # ==================== XDG 图标主题（无条件生效） ====================
  xdg.iconTheme = {
    enable = true;
    name = "Papirus-Dark";
  };

  # ==================== Hyprland 主题配色（仅 Hyprland 启用时写入） ====================
  # 条件化逻辑内联到 option 值内部，不在模块顶层表达式引用 config
  wayland.windowManager.hyprland.settings =
    let existingSettings = config.wayland.windowManager.hyprland.settings or {};
        existingDecoration = existingSettings.decoration or {};
    in lib.mkIf (config.wayland.windowManager.hyprland.enable or false) (lib.mkMerge [
      {
        general = {
          col.active_border = "rgba(34, 197, 94)";
          col.inactive_border = "rgba(71, 85, 105)";
        };
      }
      {
        decoration = lib.mkMerge [
          existingDecoration
          {
            rounding = 12;
            blur = true;
            blur_size = 3;
            blur_passes = 2;
            blur_new_windows = true;
            shadow = true;
            shadow_range = 4;
            shadow_render_power = 3;
          }
        ];
      }
    ]);

  # ==================== Niri 主题配色（仅 Niri 启用时写入） ====================
  wayland.windowManager.niri.settings =
    let existingSettings = config.wayland.windowManager.niri.settings or {};
        existingStrip = existingSettings."workspace-strip" or {};
    in lib.mkIf (config.wayland.windowManager.niri.enable or false) (lib.mkMerge [
      {
        border-color = "rgba(34, 197, 94)";
        inactive-border-color = "rgba(71, 85, 105)";
      }
      {
        "workspace-strip" = lib.mkMerge [
          existingStrip
          {
            show-workspace-numbers = true;
            show-window-titles = true;
          }
        ];
      }
    ]);
}
