# 统一主题配置（Home Manager 用户级）
#
# 提供 GTK 主题、XDG 图标主题、Hyprland/Niri 窗口配色等用户级主题配置
#
# 注意:
# - gtk、xdg.iconTheme、wayland.windowManager.* 是 Home Manager 选项
# - NixOS 系统级主题（Qt、SDDM、环境变量）在 modules/desktops/unified-theme.nix
# - HM 26.05+: gtk.gtk4.theme 不再默认镜像 gtk.theme，需显式设置
#
# 关键设计：
# - GTK/XDG 块无条件生效（不依赖 WM 模块是否加载）
# - Hyprland/Niri 主题块用两层条件：
#   1) 顶层属性存在性：config.wayland.windowManager ? <wm>
#      （检查 HM 模块是否已加载，避免 unmatched definition）
#   2) 值内部 enable 检查：lib.mkIf (config.wayland.windowManager.<wm>.enable or false)
# - ? 操作符只检查 attrset key 存在性，不强制展开 config thunk 的值，
#   所以不会触发 desktop.nix 子模块那种 imports→config thunk→merge→imports 的循环
{ pkgs, config, lib, ... }:

# 基础块：GTK/XDG（永远写入）
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

// lib.optionalAttrs (config.wayland.windowManager ? hyprland) {
  # ==================== Hyprland 主题配色（仅 Hyprland HM 模块已加载时才追加） ====================
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
}

// lib.optionalAttrs (config.wayland.windowManager ? niri) {
  # ==================== Niri 主题配色（仅 Niri HM 模块已加载时才追加） ====================
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
