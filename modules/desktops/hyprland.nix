# Hyprland 窗口管理器配置模块
# 基于 Hyprnix 管理的动态平铺 Wayland 窗口管理器
# 主题配色由 unified-theme.nix 统一管理
{ config, pkgs, inputs, ... }:

{
  # 导入依赖模块
  imports = [
    inputs.hyprnix.nixosModules.default  # Hyprnix 模块
    ./unified-theme.nix                   # 统一主题配置（GTK、Qt、Hyprland、Niri、SDDM）
  ];

  # Hyprland 主配置
  hyprland = {
    enable = true;  # 启用 Hyprland
    package = pkgs.hyprland;  # 使用 NixOS 库中的 Hyprland

    # 启用的 Hyprland 插件
    plugins = with pkgs; [
      hyprland-plugins.hyprbars   # 窗口标题栏插件
      hyprland-plugins.hyprfocus  # 焦点高亮插件
      hyprland-plugins.hyprdecor  # 窗口装饰插件
    ];

    # Hyprland 设置（主题配色由 unified-theme.nix 统一管理）
    settings = {
      # 通用设置
      general = {
        layout = "master";              # 默认布局：master 布局
        gaps_in = 5;                   # 窗口内边距
        gaps_out = 10;                  # 窗口外边距
        border_size = 2;                # 边框大小
        # col.active_border 和 col.inactive_border 由 unified-theme.nix 管理
        resize_on_border = true;        # 允许边框调整大小
        no_wallpaper = false;           # 使用壁纸
      };

      # 输入设备设置
      input = {
        kb_layout = "us,cn";            # 键盘布局：英文、中文
        kb_variant = ",";               # 键盘变体
        kb_options = "grp:alt_shift_toggle"; # 切换布局：Alt+Shift
        kb_rules = "evdev";             # 键盘规则
        touchpad = {
          natural_scroll = true;         # 自然滚动
          tap_to_click = true;           # 点击触摸
          drag_lock = true;              # 拖拽锁定
        };
        sensitivity = 0;                # 鼠标灵敏度
      };

      # 窗口装饰设置（由 unified-theme.nix 管理 rounding、blur、shadow）
      decoration = { };

      # 动画设置
      animations = {
        enabled = true;                 # 启用动画
        bezier = "overshoot,0.4,1,0.2,1"; # 贝塞尔曲线
        animation = [
          "windows,1,7,overshoot"      # 窗口动画
          "fade,1,7,default"           # 淡入淡出动画
          "workspaces,1,7,default"     # 工作区切换动画
        ];
      };

      # 杂项设置
      misc = {
        disable_hyprland_logo = true;   # 禁用启动 Logo
        disable_splash_rendering = true; # 禁用启动画面
        xwayland = true;                # 启用 Xwayland 兼容
      };

      # 窗口规则
      windowrulev2 = [
        "rule = float,class:^(kitty)$"      # Kitty 终端浮动
        "rule = float,class:^(alacritty)$"  # Alacritty 终端浮动
        "rule = float,class:^(rofi)$"       # Rofi 浮动
        "rule = float,class:^(nemo)$"       # Nemo 文件管理器浮动
      ];
    };

    # 键盘快捷键
    keybinds = {
      "SUPER,Q" = "killactive";              # 关闭活动窗口
      "SUPER,E" = "exec nemo";               # 打开文件管理器
      "SUPER,R" = "exec rofi -show drun";    # 打开应用启动器
      "SUPER,RETURN" = "exec foot";          # 打开终端（foot）
      "SUPER,C" = "exec code";               # 打开 VS Code
      "SUPER,P" = "exec rofi -show powermenu"; # 打开电源菜单
      "SUPER,H" = "movefocus left";          # 焦点左移
      "SUPER,J" = "movefocus down";          # 焦点下移
      "SUPER,K" = "movefocus up";            # 焦点上移
      "SUPER,L" = "movefocus right";         # 焦点右移
      "SUPER,S,H" = "resizeactive -10 0";    # 调整窗口大小：左
      "SUPER,S,J" = "resizeactive 0 10";     # 调整窗口大小：下
      "SUPER,S,K" = "resizeactive 0 -10";    # 调整窗口大小：上
      "SUPER,S,L" = "resizeactive 10 0";     # 调整窗口大小：右
      "SUPER,1" = "workspace 1";             # 切换到工作区 1
      "SUPER,2" = "workspace 2";             # 切换到工作区 2
      "SUPER,3" = "workspace 3";             # 切换到工作区 3
      "SUPER,4" = "workspace 4";             # 切换到工作区 4
      "SUPER,5" = "workspace 5";             # 切换到工作区 5
      "SUPER,S,1" = "movetoworkspace 1";     # 移动窗口到工作区 1
      "SUPER,S,2" = "movetoworkspace 2";     # 移动窗口到工作区 2
      "SUPER,S,3" = "movetoworkspace 3";     # 移动窗口到工作区 3
      "SUPER,S,4" = "movetoworkspace 4";     # 移动窗口到工作区 4
      "SUPER,S,5" = "movetoworkspace 5";     # 移动窗口到工作区 5
      "SUPER,F" = "togglefloating";          # 切换浮动模式
      "SUPER,FULL" = "fullscreen";           # 全屏
      "SUPER,S,F" = "swapnext";              # 交换窗口位置
      "ALT,SHIFT,F" = "fakefullscreen";      # 伪全屏
    };

    # 鼠标绑定
    binds = {
      "mouse,1" = "movewindow";              # 左键移动窗口
      "mouse,2" = "resizewindow";            # 中键调整大小
      "mouse,3" = "togglefloating";          # 右键切换浮动
      "mouse,8" = "pass";                    # 侧键后（后退）- 传递给应用程序处理
      "mouse,9" = "pass";                    # 侧键前（前进）- 传递给应用程序处理
    };
  };

  # Hyprland 相关系统包（仅系统级必需的，用户级包在 home/common/apps.nix 中）
  # polkit 代理由 desktop.nix 根据配置选择（polkit-kde-agent-1 或 hyprpolkitagent）
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-hyprland  # Hyprland 桌面门户
    hyprpaper               # Hyprland 壁纸工具
    hyprpicker              # 颜色拾取工具
    xwayland                # Xwayland 兼容层
  ];
}