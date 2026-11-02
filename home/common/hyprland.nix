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

      xwayland = {
        enable = true;
      };

      windowrulev2 = [
        "rule = float,class:^(foot)$"
        "rule = float,class:^(kitty)$"
        "rule = float,class:^(alacritty)$"
        "rule = float,class:^(rofi)$"
        "rule = float,class:^(nemo)$"
      ];
    };

    # 键盘快捷键
    keybinds = {
      "SUPER,Q" = "killactive";
      "SUPER,E" = "exec nemo";
      "SUPER,R" = "exec rofi -show drun";
      "SUPER,RETURN" = "exec foot";
      "SUPER,C" = "exec codium";
      "SUPER,B" = "exec firefox";
      "SUPER,P" = "exec rofi -show powermenu";
      "SUPER,H" = "movefocus left";
      "SUPER,J" = "movefocus down";
      "SUPER,K" = "movefocus up";
      "SUPER,L" = "movefocus right";
      "SUPER,S,H" = "resizeactive -10 0";
      "SUPER,S,J" = "resizeactive 0 10";
      "SUPER,S,K" = "resizeactive 0 -10";
      "SUPER,S,L" = "resizeactive 10 0";
      "SUPER,1" = "workspace 1";
      "SUPER,2" = "workspace 2";
      "SUPER,3" = "workspace 3";
      "SUPER,4" = "workspace 4";
      "SUPER,5" = "workspace 5";
      "SUPER,S,1" = "movetoworkspace 1";
      "SUPER,S,2" = "movetoworkspace 2";
      "SUPER,S,3" = "movetoworkspace 3";
      "SUPER,S,4" = "movetoworkspace 4";
      "SUPER,S,5" = "movetoworkspace 5";
      "SUPER,F" = "togglefloating";
      "SUPER,FULL" = "fullscreen";
      "SUPER,S,F" = "swapnext";
      "ALT,SHIFT,F" = "fakefullscreen";
    };

    # 鼠标绑定
    binds = {
      "mouse,1" = "movewindow";
      "mouse,2" = "resizewindow";
      "mouse,3" = "togglefloating";
      "mouse,8" = "pass";
      "mouse,9" = "pass";
    };
  };
}
