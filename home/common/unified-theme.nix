# 统一主题配置（Home Manager 用户级）
#
# 提供 GTK 主题、XDG 图标主题、Hyprland/Niri 窗口配色等用户级主题配置
#
# 注意:
# - gtk、xdg.iconTheme、wayland.windowManager.* 是 Home Manager 选项
# - NixOS 系统级主题（Qt、SDDM、环境变量）在 modules/desktops/unified-theme.nix
# - HM 26.05+: gtk.gtk4.theme 不再默认镜像 gtk.theme，需显式设置
{ pkgs, config, lib, ... }:

# GTK / XDG 无条件生效；Hyprland / Niri 主题只有对应 HM 模块加载且启用时才写入。
# 这样既避免「属性 niri 不存在」（READ 侧），也避免「unmatched definition」（WRITE 侧）。
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

// lib.optionalAttrs (config.wayland.windowManager ? hyprland && config.wayland.windowManager.hyprland.enable) {
  # ==================== Hyprland 主题配色 ====================
  wayland.windowManager.hyprland.settings = lib.mkMerge [
    {
      general = {
        col.active_border = "rgba(34, 197, 94)";
        col.inactive_border = "rgba(71, 85, 105)";
      };
    }
    {
      decoration = lib.mkMerge [
        ((config.wayland.windowManager.hyprland.settings or {}).decoration or {})
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
  ];
}

// lib.optionalAttrs (config.wayland.windowManager ? niri && config.wayland.windowManager.niri.enable) {
  # ==================== Niri 主题配色 ====================
  wayland.windowManager.niri.settings = lib.mkMerge [
    {
      border-color = "rgba(34, 197, 94)";
      inactive-border-color = "rgba(71, 85, 105)";
    }
    {
      workspace-strip = lib.mkMerge [
        ((config.wayland.windowManager.niri.settings or {}).workspace-strip or {})
        {
          show-workspace-numbers = true;
          show-window-titles = true;
        }
      ];
    }
  ];
}
