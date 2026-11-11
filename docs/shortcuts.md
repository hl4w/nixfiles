# HL4W NixOS Configuration - 快捷键参考

**Version: v0.0.6**

本文档详细说明 Hyprland 和 Niri 窗口管理器的快捷键配置，与 `home/common/hyprland.nix` / `home/common/niri.nix` 中的实际配置一一对应。两个窗口管理器默认提供 5 个工作区。

> Hyprland 0.55 起配置格式为 **Lua**（Home Manager `configType = "lua"`，生成 `~/.config/hypr/hyprland.lua`），下表「Hyprland 命令」列对应 Lua dispatcher `hl.dsp.*`。

---

## Hyprland 快捷键

**配置摘要**：Lua 配置格式；master 布局，gaps 5/10（内/外），边框 2px，圆角 12px，模糊与阴影启用；动画启用（windows / fade / workspaces，速度 7）；XWayland 启用。

### 基础操作

| 快捷键 | 功能 | Lua dispatcher |
|--------|------|----------------|
| `Super + Q` | 关闭活动窗口 | `hl.dsp.window.close()` |
| `Super + E` | 打开文件管理器 | `hl.dsp.exec_cmd("nemo")` |
| `Super + R` | 打开应用启动器 | `hl.dsp.exec_cmd("rofi -show drun")` |
| `Super + Return` | 打开终端 | `hl.dsp.exec_cmd("foot")` |
| `Super + C` | 打开编辑器 | `hl.dsp.exec_cmd("codium")` |
| `Super + B` | 打开浏览器 | `hl.dsp.exec_cmd("firefox")` |
| `Super + P` | 打开电源菜单 | `hl.dsp.exec_cmd("rofi -show powermenu")` |

### 窗口移动（方向键 = hjkl）

| 快捷键 | 功能 | Lua dispatcher |
|--------|------|----------------|
| `Super + H` | 窗口左移 | `hl.dsp.window.move({ direction = "left" })` |
| `Super + J` | 窗口下移 | `hl.dsp.window.move({ direction = "down" })` |
| `Super + K` | 窗口上移 | `hl.dsp.window.move({ direction = "up" })` |
| `Super + L` | 窗口右移 | `hl.dsp.window.move({ direction = "right" })` |

### 窗口大小调整（每次 ±10px）

| 快捷键 | 功能 | Lua dispatcher |
|--------|------|----------------|
| `Super + Shift + H` | 向左缩窄 | `hl.dsp.window.resize({ x = -10, y = 0, relative = true })` |
| `Super + Shift + J` | 向下加高 | `hl.dsp.window.resize({ x = 0, y = 10, relative = true })` |
| `Super + Shift + K` | 向上缩矮 | `hl.dsp.window.resize({ x = 0, y = -10, relative = true })` |
| `Super + Shift + L` | 向右加宽 | `hl.dsp.window.resize({ x = 10, y = 0, relative = true })` |

### 工作区操作（共 5 个）

| 快捷键 | 功能 | Lua dispatcher |
|--------|------|----------------|
| `Super + 1` – `Super + 5` | 切换到对应工作区 | `hl.dsp.focus({ workspace = N })` |
| `Super + Shift + 1` – `Super + Shift + 5` | 将活动窗口移动到对应工作区 | `hl.dsp.window.move({ workspace = N })` |

### 窗口状态

| 快捷键 | 功能 | Lua dispatcher |
|--------|------|----------------|
| `Super + F` | 切换浮动模式 | `hl.dsp.window.float({ action = "toggle" })` |
| `Super + Shift + Return` | 切换全屏 | `hl.dsp.window.fullscreen({ action = "toggle" })` |
| `Super + Shift + F` | 与下一个窗口交换位置 | `hl.dsp.window.swap({ next = true })` |

### 鼠标绑定

鼠标绑定通过 `hl.bind(..., { mouse = true; })` 注册。

| 鼠标按钮 | 功能 | Lua dispatcher |
|----------|------|----------------|
| `Super + 左键拖动` | 移动窗口 | `hl.dsp.window.drag()` |
| `Super + 中键拖动` | 调整窗口大小 | `hl.dsp.window.resize()` |
| `Super + 右键` | 切换浮动模式 | `hl.dsp.window.float({ action = "toggle" })` |

---

## Niri 快捷键

**配置摘要**：gaps 8px，边框 2px，工作区条在顶部（显示工作区编号与窗口标题），字体 JetBrainsMono Nerd Font 14。Niri 为可滚动平铺窗口管理器，窗口焦点/大小通过鼠标滚轮和手势处理，不额外绑定方向键。

### 基础操作

| 快捷键 | 功能 | 执行动作 |
|--------|------|----------|
| `Super + Shift + Return` | 打开终端 | `spawn "foot"` |
| `Super + D` | 打开应用启动器 | `spawn "rofi -show drun"` |
| `Super + E` | 打开文件管理器 | `spawn "nemo"` |
| `Super + B` | 打开浏览器 | `spawn "firefox"` |
| `Super + Q` | 关闭窗口 | `close-window` |
| `Super + C` | 打开编辑器 | `spawn "codium"` |
| `Super + P` | 打开电源菜单 | `spawn "rofi -show powermenu"` |
| `Super + Shift + E` | 电源菜单（Niri 内置动作） | `power-menu` |
| `Super + Shift + Q` | 退出 Niri | `quit` |

---

## 通用说明

### Super 键

本配置中 `Super` 键指 **Windows 键**；macOS 键盘上对应 **Command 键**。

### 键盘布局

- Hyprland XKB 布局设为 `us`（`settings.config.input.kb_layout = "us"`），中文输入由 Fcitx5 处理，无需单独的 CN 布局
- `Alt + Shift` 保留为布局切换组合键（`kb_options = "grp:alt_shift_toggle"`）

### 浮动窗口规则

以下应用默认以浮动模式打开（Hyprland `settings.window_rule`，按 `match.class` 正则匹配）：

| 应用 | class 正则 |
|------|-----------|
| Foot 终端 | `foot` |
| Kitty 终端 | `kitty` |
| Alacritty 终端 | `alacritty` |
| Rofi | `rofi` |
| Nemo 文件管理器 | `nemo` |

合并后的规则为一条：`match.class = "^(foot|kitty|alacritty|rofi|nemo)$"`、`float = true`。

### 自定义快捷键

如需修改快捷键，编辑对应窗口管理器的配置文件：

- **Hyprland**：`home/common/hyprland.nix`（`settings.bind` / `settings.window_rule` / `settings.config`，Lua 格式），系统级启用位于 `modules/desktops/hyprland.nix`
- **Niri**：`home/common/niri.nix`（`xdg.configFile."niri/config.kdl"` 中的 `binds` 块），系统级启用位于 `modules/desktops/niri.nix`

Hyprland 键位语法为修饰键之间用 `" + "` 连接（如 `"SUPER + SHIFT + Q"`），合法修饰键为 `SHIFT` / `CTRL` / `ALT` / `SUPER` / `MOD1`–`MOD5`。

修改后执行 `home-manager switch --flake .#<username>@<hostname>` 生效。
