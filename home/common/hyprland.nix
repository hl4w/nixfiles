# Hyprland 窗口管理器 - Home Manager 配置
#
# 使用 Home Manager 的 wayland.windowManager.hyprland 模块
# 管理 Hyprland 的用户级配置（settings / 窗口规则 / 按键绑定）
#
# Hyprland 0.55 起官方配置格式为 Lua（$XDG_CONFIG_HOME/hypr/hyprland.lua），
# 存在该文件时会忽略同目录的 hyprland.conf；hyprlang 仅保留 1-2 个 release 的兼容期。
# Home Manager release-26.05 的 hyprland 模块原生支持 configType = "lua"：
#   - 生成 $XDG_CONFIG_HOME/hypr/hyprland.lua
#   - 生成 $XDG_CONFIG_HOME/hypr/.luarc.json（指向包的 Lua stubs，便于编辑器补全）
#
# settings 在 lua 模式下的映射规则（官方文档）：
#   每个 attribute  → 一次 hl.<name>(...) 调用
#   list 值         → 每个元素一次调用
#   _args 列表      → 多参数调用
#   _var            → 生成 Lua 局部变量，而非函数调用
#   mkLuaInline     → 原样输出 Lua 表达式
#
# 系统级配置（安装包、桌面会话）在 modules/desktops/hyprland.nix
# 通过 programs.hyprland.enable = true 管理
{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;

  # 原样输出 Lua 表达式（不做字符串转义）
  lua = mkLuaInline;

  # 构造一条 hl.bind() 调用：
  #   key      —— Hyprland 0.55 键位语法，修饰键之间用 " + " 连接
  #   dispatch —— Lua dispatcher 表达式字符串
  #   extra    —— 可选的第三参数（如 { mouse = true; }），null 表示省略
  kb = key: dispatch: extra: {
    _args = [ key (lua dispatch) ] ++ lib.optional (extra != null) extra;
  };

  # 工作区编号（1-5），用于批量生成切换 / 移动绑定
  workspaceIds = [ 1 2 3 4 5 ];
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;

    # Hyprland 0.55+ 官方配置格式
    configType = "lua";

    settings = {
      # ── 全局配置（一次 hl.config({...}) 调用）──────────────────────────────
      # 注意：theme-hyprland.nix 会向同一 attrset 追加 general.col / decoration，
      #       Home Manager 会自动做深层 attrset 合并，此处无需（也不应）重复声明。
      config = {
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

        animations = {
          enabled = true;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };
      };

      # ── 动画曲线与动画条目（每条生成一次 hl.curve / hl.animation）──────────
      # 0.55 Lua 把 hyprlang 的 "bezier = name,.." 拆成 hl.curve(name, {...})
      curve = [
        {
          _args = [
            "overshoot"
            {
              type = "bezier";
              points = [
                [ 0.4 1 ]
                [ 0.2 1 ]
              ];
            }
          ];
        }
      ];

      animation = [
        {
          leaf = "windows";
          enabled = true;
          speed = 7;
          bezier = "overshoot";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 7;
          bezier = "default";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 7;
          bezier = "default";
        }
      ];

      # ── 窗口规则（hyprlang 的 windowrulev2 → hl.window_rule）──────────────
      window_rule = [
        {
          name = "float-apps";
          match.class = "^(foot|kitty|alacritty|rofi|nemo)$";
          float = true;
        }
      ];

      # ── 键盘 / 鼠标绑定（hyprlang 的 bind / bindm → hl.bind）───────────────
      # 鼠标绑定在 0.55 中不再单独建表，而是给 hl.bind 传 { mouse = true; }
      bind = [
        # 窗口 / 程序
        (kb "SUPER + Q" "hl.dsp.window.close()" null)
        (kb "SUPER + E" "hl.dsp.exec_cmd(\"nemo\")" null)
        (kb "SUPER + R" "hl.dsp.exec_cmd(\"rofi -show drun\")" null)
        (kb "SUPER + RETURN" "hl.dsp.exec_cmd(\"foot\")" null)
        (kb "SUPER + C" "hl.dsp.exec_cmd(\"codium\")" null)
        (kb "SUPER + B" "hl.dsp.exec_cmd(\"firefox\")" null)
        (kb "SUPER + P" "hl.dsp.exec_cmd(\"rofi -show powermenu\")" null)

        # 窗口移动（方向参数需全名 left/down/up/right）
        (kb "SUPER + H" "hl.dsp.window.move({ direction = \"left\" })" null)
        (kb "SUPER + J" "hl.dsp.window.move({ direction = \"down\" })" null)
        (kb "SUPER + K" "hl.dsp.window.move({ direction = \"up\" })" null)
        (kb "SUPER + L" "hl.dsp.window.move({ direction = \"right\" })" null)

        # 窗口缩放（相对尺寸，relative = true）
        (kb "SUPER + SHIFT + H" "hl.dsp.window.resize({ x = -10, y = 0, relative = true })" null)
        (kb "SUPER + SHIFT + J" "hl.dsp.window.resize({ x = 0, y = 10, relative = true })" null)
        (kb "SUPER + SHIFT + K" "hl.dsp.window.resize({ x = 0, y = -10, relative = true })" null)
        (kb "SUPER + SHIFT + L" "hl.dsp.window.resize({ x = 10, y = 0, relative = true })" null)

        # 窗口状态
        (kb "SUPER + F" "hl.dsp.window.float({ action = \"toggle\" })" null)
        (kb "SUPER + SHIFT + RETURN" "hl.dsp.window.fullscreen({ action = \"toggle\" })" null)
        (kb "SUPER + SHIFT + F" "hl.dsp.window.swap({ next = true })" null)

        # 鼠标：左键拖动、右键调整大小、中键切换浮动
        (kb "SUPER + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
        (kb "SUPER + mouse:273" "hl.dsp.window.resize()" { mouse = true; })
        (kb "SUPER + mouse:274" "hl.dsp.window.float({ action = \"toggle\" })" null)
      ]
      # 工作区 1-5：SUPER+N 切换，SUPER+SHIFT+N 把窗口移过去
      ++ lib.concatMap (
        n:
        let
          id = toString n;
        in
        [
          (kb "SUPER + ${id}" "hl.dsp.focus({ workspace = ${id} })" null)
          (kb "SUPER + SHIFT + ${id}" "hl.dsp.window.move({ workspace = ${id} })" null)
        ]
      ) workspaceIds;
    };
  };
}
