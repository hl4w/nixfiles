# Hyprland 窗口管理器 - Home Manager 配置
#
# 使用 Home Manager 的 wayland.windowManager.hyprland 模块
# 管理 Hyprland 的详细配置（settings、keybinds、binds 等）
#
# 系统级配置（安装包、桌面会话）在 modules/desktops/hyprland.nix
# 通过 programs.hyprland.enable = true 管理
{ pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;

    # Hyprland 0.55+ 默认 Lua 配置格式
    # 当前使用 hyprlang（Hyprland 原生命令式格式），需显式声明
    configType = "hyprlang";

    # Hyprland 设置
    settings = {
      general = {
        layout = "master";
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        resize_on_border = true;
        no_wallpaper = false;
      };

      input = {
        kb_layout = "us";                 # 键盘布局（中文由 fcitx5 处理，无需 cn）
        kb_variant = "";
        kb_options = "grp:alt_shift_toggle";
        kb_rules = "evdev";
        touchpad = {
          natural_scroll = true;
          tap_to_click = true;
          drag_lock = true;
        };
        sensitivity = 0;
      };

      decoration = { };

      animations = {
        enabled = true;
        bezier = "overshoot,0.4,1,0.2,1";
        animation = [
          "windows,1,7,overshoot"
          "fade,1,7,default"
          "workspaces,1,7,default"
        ];
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      windowrulev2 = [
        "float,class:^(foot)$"
        "float,class:^(kitty)$"
        "float,class:^(alacritty)$"
        "float,class:^(rofi)$"
        "float,class:^(nemo)$"
      ];

      # 键盘与鼠标绑定
      # Home Manager 的 hyprland 模块没有 keybinds / binds 选项，
      # 统一写入 settings.bind / settings.bindm（Hyprland 原生命令）
      bind = [
        "SUPER, Q, killactive"
        "SUPER, E, exec, nemo"
        "SUPER, R, exec, rofi -show drun"
        "SUPER, RETURN, exec, foot"
        "SUPER, C, exec, codium"
        "SUPER, B, exec, firefox"
        "SUPER, P, exec, rofi -show powermenu"
        "SUPER, H, movewindow, left"
        "SUPER, J, movewindow, down"
        "SUPER, K, movewindow, up"
        "SUPER, L, movewindow, right"
        "SUPER SHIFT, H, resizeactive, -10, 0"
        "SUPER SHIFT, J, resizeactive, 0, 10"
        "SUPER SHIFT, K, resizeactive, 0, -10"
        "SUPER SHIFT, L, resizeactive, 10, 0"
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER, F, togglefloating"
        "SUPER, FULL, fullscreen"
        "SUPER SHIFT, F, swapnext"
       # "ALT, SHIFT, F, fakefullscreen"
      ];

      # 鼠标绑定（bindm：左键拖动窗口、右键调整大小、中键切换浮动）
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
        "SUPER, mouse:274, togglefloating"
      ];
    };
  };
}
