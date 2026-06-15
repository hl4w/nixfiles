# 统一主题配置模块
# 为 GTK、Qt、Hyprland、SDDM、Noctalia-Shell 和 DMS-Shell 提供统一的配色、图标和字体
# 支持壁纸自动取色配色（pywal）
# 支持日夜自动切换主题风格
{ pkgs, lib, ... }:

let
  # ==================== 主题模式配置 ====================
  # 主题模式：dark（深色）、light（浅色）、auto（自动根据时间切换）
  themeMode = lib.mkDefault "auto";
  
  # 日夜切换时间配置
  dayStart = lib.mkDefault 6;    # 白天开始时间（小时）
  nightStart = lib.mkDefault 18; # 夜晚开始时间（小时）
  
  # 窗口管理器配置由 desktop.nix 的 windowManager 选项管理
  # install.sh 生成的配置会设置 desktop.windowManager

  # 根据时间判断当前应该使用的主题
  getThemeMode = pkgs.writeScript "get-theme-mode" ''
    #!/bin/sh
    HOUR=$(date +%H)
    DAY_START=${dayStart}
    NIGHT_START=${nightStart}
    
    if [ "${themeMode}" = "dark" ]; then
        echo "dark"
    elif [ "${themeMode}" = "light" ]; then
        echo "light"
    else
        # 自动模式：6:00-18:00 为白天，其余为夜晚
        if [ $HOUR -ge $DAY_START ] && [ $HOUR -lt $NIGHT_START ]; then
            echo "light"
        else
            echo "dark"
        fi
    fi
  '';

  # 根据主题模式返回对应的主题名称
  getGTKTheme = mode: if mode == "dark" then "Adwaita-dark" else "Adwaita";
  getQtStyle = mode: if mode == "dark" then "adwaita-dark" else "adwaita";
  getIconTheme = mode: if mode == "dark" then "Papirus-Dark" else "Papirus";
  getShellTheme = mode: if mode == "dark" then "dark" else "light";
  
  # 动态生成主题切换脚本
  themeSwitcher = pkgs.writeScript "theme-switcher" ''
    #!/bin/sh
    MODE=$(${getThemeMode})
    
    # 设置环境变量
    export GTK_THEME=$(if [ "$MODE" = "dark" ]; then echo "Adwaita-dark"; else echo "Adwaita"; fi)
    export QT_STYLE_OVERRIDE=$(if [ "$MODE" = "dark" ]; then echo "adwaita-dark"; else echo "adwaita"; fi)
    export XDG_ICON_THEME=$(if [ "$MODE" = "dark" ]; then echo "Papirus-Dark"; else echo "Papirus"; fi)
    
    # 更新 GTK 配置文件
    mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
    
    cat > ~/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$XDG_ICON_THEME
gtk-font-name=Noto Sans 11
EOF
    
    cat > ~/.config/gtk-4.0/settings.ini << EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$XDG_ICON_THEME
gtk-font-name=Noto Sans 11
EOF
    
    # 更新 Qt 配置
    mkdir -p ~/.config
    cat > ~/.config/Trolltech.conf << EOF
[Qt]
style=$QT_STYLE_OVERRIDE
iconTheme=$XDG_ICON_THEME
EOF
    
    echo "Theme switched to: $MODE"
  '';
in
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
    # 窗口管理器配置由 desktop.nix 的 windowManager 选项管理
    # 不在此处重复定义，使用 config.desktop.windowManager 获取
  };

  config = let
    currentThemeMode = config.desktop.unified-theme.themeMode;
    startDay = config.desktop.unified-theme.dayStart;
    startNight = config.desktop.unified-theme.nightStart;
    # 使用 desktop.nix 的 windowManager 配置（由 install.sh 生成）
    currentDesktopManager = config.desktop.windowManager;
  in {
    # 字体配置独立在 modules/system/fonts.nix 中管理

    # ==================== 环境变量（合并去重） ====================
    environment.sessionVariables = {
      # pywal 配置
      WAL_CACHE_DIR = "$HOME/.cache/wal";
      WALLPAPER_DIR = "$HOME/.wallpapers";
      
      # 主题模式配置
      THEME_MODE = currentThemeMode;
      THEME_DAY_START = "${toString startDay}";
      THEME_NIGHT_START = "${toString startNight}";

      # GTK/Qt 主题（默认使用深色，运行时可切换）
      GTK_THEME = "Adwaita-dark";
      GTK2_RC_FILES = "${pkgs.gnome.gnome-themes-extra}/share/themes/Adwaita-dark/gtk-2.0/gtkrc";
      QT_STYLE_OVERRIDE = "adwaita-dark";
      QT_QPA_PLATFORMTHEME = "gtk3";
      QT_QPA_FONTDIR = "${pkgs.noto-fonts}/share/fonts";
      XDG_ICON_THEME = "Papirus-Dark";
      XDG_DATA_DIRS = "${pkgs.papirus-icon-theme}/share:${pkgs.gnome.adwaita-icon-theme}/share:${pkgs.kdePackages.breeze-icons}/share:/usr/share";

      # 桌面环境标识（根据配置的桌面管理器动态设置）
      XDG_CURRENT_DESKTOP = (if currentDesktopManager == "hyprland" then "Hyprland" else "Niri");
      XDG_SESSION_DESKTOP = (if currentDesktopManager == "hyprland" then "Hyprland" else "Niri");
      XDG_SESSION_TYPE = "wayland";
    };

    # ==================== GTK 主题配置 ====================
    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.adwaita-icon-theme;
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
    };

    # ==================== Qt 主题配置 ====================
    qt = {
      enable = true;
      style = "adwaita-dark";
      platformTheme = "gtk3";
      iconTheme = "Papirus-Dark";
      font = {
        name = "Noto Sans";
        size = 11;
      };
    };

    # 字体配置独立在 modules/system/fonts.nix 中管理

    # ==================== XDG 图标主题 ====================
    xdg.iconTheme = {
      enable = true;
      name = "Papirus-Dark";
    };

    # ==================== SDDM 登录界面主题 ====================
    services.sddm = lib.mkIf config.services.sddm.enable {
      theme = "breeze";
      greeterEnvironment = {
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        GTK_THEME = "Adwaita-dark";
        QT_STYLE_OVERRIDE = "adwaita-dark";
        XDG_ICON_THEME = "Papirus-Dark";
      };
    };

    # ==================== Hyprland 主题配色 ====================
    wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkMerge [
      # 窗口边框颜色
      {
        general = {
          col.active_border = "rgba(34, 197, 94)";   # 活动窗口边框（绿色）
          col.inactive_border = "rgba(71, 85, 105)"; # 非活动窗口边框（灰色）
        };
      }
      # 窗口装饰设置（合并而非覆盖）
      {
        decoration = lib.mkMerge [
          config.hyprland.settings.decoration or {}
          {
            rounding = 12;                  # 圆角半径
            blur = true;                    # 启用模糊
            blur_size = 3;                  # 模糊大小
            blur_passes = 2;                # 模糊次数
            blur_new_windows = true;        # 新窗口启用模糊
            shadow = true;                  # 启用阴影
            shadow_range = 4;               # 阴影范围
            shadow_render_power = 3;        # 阴影渲染强度
          }
        ];
      }
    ]);

    # ==================== Niri 窗口管理器主题配色 ====================
    wayland.windowManager.niri.settings = lib.mkIf config.wayland.windowManager.niri.enable (lib.mkMerge [
      # 窗口边框颜色（与 Hyprland 保持一致）
      {
        border-color = "rgba(34, 197, 94)";              # 活动窗口边框（绿色）
        inactive-border-color = "rgba(71, 85, 105)";     # 非活动窗口边框（灰色）
      }
      # 工作区条配置（合并而非覆盖）
      {
        workspace-strip = lib.mkMerge [
          config.wayland.windowManager.niri.settings.workspace-strip or {}
          {
            show-workspace-numbers = true;   # 显示工作区编号
            show-window-titles = true;       # 显示窗口标题
          }
        ];
      }
    ]);

    # ==================== Noctalia-Shell 主题配置 ====================
    programs.noctalia-shell = lib.mkIf (pkgs ? noctalia-shell) {
      enable = true;
      theme = "dark";
      iconTheme = "Papirus-Dark";
      font = {
        name = "Noto Sans";
        size = 11;
      };
    };

    # ==================== DMS-Shell 主题配置 ====================
    programs.dms-shell = lib.mkIf (pkgs ? dms-shell) {
      enable = true;
      theme = "dark";
      iconTheme = "Papirus-Dark";
      font = {
        name = "Noto Sans";
        size = 11;
      };
    };

    # ==================== 额外的 GTK/Qt 配置文件和壁纸目录 ====================
    environment.etc = {
      # 确保壁纸目录存在，并从项目复制默认壁纸
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
      # 壁纸取色工具
      pywal              # 壁纸取色工具 - 从壁纸提取颜色
      imagemagick        # 图像处理依赖
      python3            # Python 支持

      # 图标主题（额外的图标主题）
      papirus-icon-theme          # Papirus 图标主题（推荐）
      kdePackages.breeze-icons    # Breeze 图标主题（KDE）- 通过 kdePackages 获取，确保版本兼容性
      hicolor-icon-theme          # 基础图标主题

      (pkgs.writeScriptBin "theme-switch" ''
        #!/bin/sh
        MODE=$1
        
        if [ -z "$MODE" ]; then
            # 自动判断模式
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
        
        # 设置主题
        if [ "$MODE" = "dark" ]; then
            GTK_THEME="Adwaita-dark"
            QT_STYLE="adwaita-dark"
            ICON_THEME="Papirus-Dark"
        else
            GTK_THEME="Adwaita"
            QT_STYLE="adwaita"
            ICON_THEME="Papirus"
        fi
        
        # 更新环境变量
        export GTK_THEME="$GTK_THEME"
        export QT_STYLE_OVERRIDE="$QT_STYLE"
        export XDG_ICON_THEME="$ICON_THEME"
        
        # 更新用户配置文件
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
        echo "GTK Theme: $GTK_THEME"
        echo "Qt Style: $QT_STYLE"
        echo "Icon Theme: $ICON_THEME"
      '')
      
      (pkgs.writeScriptBin "theme-auto" ''
        #!/bin/sh
        # 自动根据时间切换主题
        exec theme-switch
      '')
      
      (pkgs.writeScriptBin "theme-dark" ''
        #!/bin/sh
        # 切换到深色主题
        exec theme-switch dark
      '')
      
      (pkgs.writeScriptBin "theme-light" ''
        #!/bin/sh
        # 切换到浅色主题
        exec theme-switch light
      '')
    ]);
  };
}