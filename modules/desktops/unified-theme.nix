# 统一主题配置模块（NixOS 系统级）
# 提供 Qt、SDDM、环境变量、壁纸目录等系统级主题配置
#
# 注意: GTK 主题、XDG 图标主题、Hyprland/Niri 窗口配色等用户级配置
#       由 Home Manager 模块管理（见 home/common/theme-gtk.nix、
#       theme-hyprland.nix、theme-niri.nix）。
#       因为 gtk、xdg.iconTheme、wayland.windowManager.* 是 Home Manager 选项，
#       在 NixOS 系统层不存在。
{ pkgs, config, lib, ... }:

{
  # ==================== 主题模式选项 ====================
  options.desktop.unified-theme = {
    themeMode = lib.mkOption {
      type = lib.types.enum [ "dark" "light" "auto" ];
      default = "auto";
      description = "主题模式：dark（深色）、light（浅色）、auto（自动根据时间切换）";
    };
    dayStart = lib.mkOption {
      type = lib.types.int;
      default = 6;
      description = "白天开始时间（小时），用于自动模式判断";
    };
    nightStart = lib.mkOption {
      type = lib.types.int;
      default = 18;
      description = "夜晚开始时间（小时），用于自动模式判断";
    };
  };

  config = let
    currentThemeMode = config.desktop.unified-theme.themeMode;
    startDay = config.desktop.unified-theme.dayStart;
    startNight = config.desktop.unified-theme.nightStart;
    currentDesktopManager = config.desktop.windowManager;
  in {
    # ==================== 环境变量 ====================
    # 注意: GTK_THEME / QT_STYLE_OVERRIDE / XDG_ICON_THEME 由 Home Manager 用户级配置管理，
    #       此处不再重复设置，避免环境变量覆盖 HM 的 gtk/xdg.iconTheme 模块配置
    environment.sessionVariables = {
      WAL_CACHE_DIR = "$HOME/.cache/wal";
      WALLPAPER_DIR = "$HOME/.wallpapers";

      THEME_MODE = currentThemeMode;
      THEME_DAY_START = "${toString startDay}";
      THEME_NIGHT_START = "${toString startNight}";

      # XDG 基础环境变量（非主题相关，保留）
      QT_QPA_PLATFORMTHEME = "gtk3";
      QT_QPA_FONTDIR = "${pkgs.noto-fonts}/share/fonts";
      XDG_DATA_DIRS = "${pkgs.papirus-icon-theme}/share:${pkgs.adwaita-icon-theme}/share:${pkgs.kdePackages.breeze-icons}/share:/usr/share";

      XDG_CURRENT_DESKTOP = (if currentDesktopManager == "hyprland" then "Hyprland" else "Niri");
      XDG_SESSION_DESKTOP = (if currentDesktopManager == "hyprland" then "Hyprland" else "Niri");
      XDG_SESSION_TYPE = "wayland";
    };

    # ==================== Qt 主题配置（NixOS 系统级） ====================
    # 注意: NixOS qt 模块仅支持 enable/platformTheme/style
    #       iconTheme/font 由环境变量和 Trolltech.conf 处理
    qt = {
      enable = true;
      style = "adwaita-dark";
      platformTheme = "gtk3";
    };

    # ==================== SDDM 登录界面 ====================
    # SDDM 的启用与主题（theme = "breeze"）由 modules/desktops/sddm.nix 统一配置。
    # 注意: services.displayManager.sddm 在 26.05 中只有 enable/package/theme/settings/
    #       wayland 等选项，不存在 greeterEnvironment、displayServer、themePackages。

    # ==================== 系统级 GTK/Qt 配置文件（/etc/skel） ====================
    # 这些是用户首次登录时的骨架默认值（~/.config 还没生成时生效）
    # Home Manager 配置安装后会覆盖这些系统级默认值
    environment.etc = {
      "skel/.wallpapers" = {
        source = ./../../wallpapers;
        recursive = true;
      };

      "gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=Adwaita-dark
        gtk-icon-theme-name=Papirus-Dark
        gtk-font-name=Noto Sans 11
        gtk-cursor-theme-name=Adwaita
        gtk-cursor-theme-size=24
        gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
        gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
        gtk-button-images=1
        gtk-menu-images=1
        gtk-enable-event-sounds=0
        gtk-enable-input-feedback-sounds=0
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle=hintfull
      '';

      "gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=Adwaita-dark
        gtk-icon-theme-name=Papirus-Dark
        gtk-font-name=Noto Sans 11
        gtk-cursor-theme-name=Adwaita
        gtk-cursor-theme-size=24
        gtk-enable-event-sounds=0
        gtk-enable-input-feedback-sounds=0
      '';

      "xdg/Trolltech.conf".text = ''
        [Qt]
        style=adwaita-dark
        iconTheme=Papirus-Dark
        font="Noto Sans,11,-1,5,50,0,0,0,0,0"
      '';
    };

    # ==================== 主题包和切换脚本 ====================
    environment.systemPackages = lib.mkAfter (with pkgs; [
      pywal
      imagemagick
      python3

      papirus-icon-theme
      kdePackages.breeze-icons
      hicolor-icon-theme

      (pkgs.writeScriptBin "theme-switch" ''
        #!/bin/sh
        MODE=$1

        if [ -z "$MODE" ]; then
            HOUR=$(date +%H)
            DAY_START=${startDay}
            NIGHT_START=${startNight}

            if [ "${currentThemeMode}" = "dark" ]; then
                MODE="dark"
            elif [ "${currentThemeMode}" = "light" ]; then
                MODE="light"
            else
                if [ $HOUR -ge $DAY_START ] && [ $HOUR -lt $NIGHT_START ]; then
                    MODE="light"
                else
                    MODE="dark"
                fi
            fi
        fi

        if [ "$MODE" = "dark" ]; then
            GTK_THEME="Adwaita-dark"
            QT_STYLE="adwaita-dark"
            ICON_THEME="Papirus-Dark"
        else
            GTK_THEME="Adwaita"
            QT_STYLE="adwaita"
            ICON_THEME="Papirus"
        fi

        export GTK_THEME="$GTK_THEME"
        export QT_STYLE_OVERRIDE="$QT_STYLE"
        export XDG_ICON_THEME="$ICON_THEME"

        mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

        cat > ~/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=Noto Sans 11
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
EOF

        cat > ~/.config/gtk-4.0/settings.ini << EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=Noto Sans 11
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
EOF

        mkdir -p ~/.config
        cat > ~/.config/Trolltech.conf << EOF
[Qt]
style=$QT_STYLE
iconTheme=$ICON_THEME
font="Noto Sans,11,-1,5,50,0,0,0,0,0"
EOF

        echo "Theme switched to: $MODE"
      '')

      (pkgs.writeScriptBin "theme-auto" ''
        #!/bin/sh
        exec theme-switch
      '')

      (pkgs.writeScriptBin "theme-dark" ''
        #!/bin/sh
        exec theme-switch dark
      '')

      (pkgs.writeScriptBin "theme-light" ''
        #!/bin/sh
        exec theme-switch light
      '')
    ]);
  };
}
