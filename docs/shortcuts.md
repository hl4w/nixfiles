# HL4W NixOS Configuration - 快捷键参考

**Version: v0.0.6**

本文档详细说明 Hyprland 和 Niri 窗口管理器的快捷键配置，与 `home/common/hyprland.nix` / `home/common/niri.nix` 中的实际配置一一对应。两个窗口管理器默认提供 5 个工作区。

---

## Hyprland 快捷键

**配置摘要**：master 布局，gaps 5/10（内/外），边框 2px，动画启用（窗口、淡入、工作区），XWayland 启用。

### 基础操作

| 快捷键 | 功能 | 执行命令 |
|--------|------|----------|
| `Super + Q` | 关闭活动窗口 | `killactive` |
| `Super + E` | 打开文件管理器 | `nemo` |
| `Super + R` | 打开应用启动器 | `rofi -show drun` |
| `Super + Return` | 打开终端 | `foot` |
| `Super + C` | 打开编辑器 | `codium` |
| `Super + B` | 打开浏览器 | `firefox` |
| `Super + P` | 打开电源菜单 | `rofi -show powermenu` |

### 窗口焦点移动（方向键 = hjkl）

| 快捷键 | 功能 |
|--------|------|
| `Super + H` | 焦点左移 |
| `Super + J` | 焦点下移 |
| `Super + K` | 焦点上移 |
| `Super + L` | 焦点右移 |

### 窗口大小调整（每次 ±10px）

| 快捷键 | 功能 |
|--------|------|
| `Super + Shift + H` | 窗口向左缩小 |
| `Super + Shift + J` | 窗口向下扩大 |
| `Super + Shift + K` | 窗口向上缩小 |
| `Super + Shift + L` | 窗口向右扩大 |

### 工作区操作（共 5 个）

| 快捷键 | 功能 |
|--------|------|
| `Super + 1` – `Super + 5` | 切换到对应工作区 |
| `Super + Shift + 1` – `Super + Shift + 5` | 将活动窗口移动到对应工作区 |

### 窗口状态

| 快捷键 | 功能 | Hyprland 命令 |
|--------|------|---------------|
| `Super + F` | 切换浮动模式 | `togglefloating` |
| `Super + F11` | 全屏 | `fullscreen`（`FULL` 是 Hyprland 内部键名） |
| `Super + Shift + F` | 与下一个窗口交换位置 | `swapnext` |
| `Alt + Shift + F` | 伪全屏（保留边框和标题） | `fakefullscreen` |

### 鼠标绑定

| 鼠标按钮 | 功能 | Hyprland 命令 |
|----------|------|---------------|
| 左键拖动 | 移动窗口 | `movewindow` |
| 中键拖动 | 调整窗口大小 | `resizewindow` |
| 右键 | 切换浮动模式 | `togglefloating` |
| 侧键后（8） | 透传给应用（浏览器后退等） | `pass` |
| 侧键前（9） | 透传给应用（浏览器前进等） | `pass` |

---

## Niri 快捷键

**配置摘要**：gaps 8px，边框 2px，工作区条在顶部，XWayland 启用。Niri 为可滚动平铺窗口管理器，窗口焦点/大小通过鼠标滚轮和手势处理，不额外绑定方向键。

### 基础操作

| 快捷键 | 功能 | 执行命令 |
|--------|------|----------|
| `Super + R` | 打开应用启动器 | `rofi -show drun` |
| `Super + Return` | 打开终端 | `foot` |
| `Super + E` | 打开文件管理器 | `nemo` |
| `Super + B` | 打开浏览器 | `firefox` |
| `Super + Q` | 关闭窗口 | — |
| `Super + C` | 打开编辑器 | `codium` |
| `Super + P` | 打开电源菜单 | `rofi -show powermenu` |
| `Super + Shift + Q` | 退出 Niri | — |

---

## 通用说明

### Super 键

本配置中 `Super` 键指 **Windows 键**；macOS 键盘上对应 **Command 键**。

### 键盘布局

- Hyprland XKB 布局设为 `us`（`kb_layout = "us"`），中文输入由 Fcitx5 处理，无需单独的 CN 布局
- `Alt + Shift` 保留为布局切换组合键（`kb_options = "grp:alt_shift_toggle"`）

### 浮动窗口规则

以下应用默认以浮动模式打开（Hyprland `windowrulev2`，按 `class` 匹配）：

| 应用 | class |
|------|-------|
| Foot 终端 | `foot` |
| Kitty 终端 | `kitty` |
| Alacritty 终端 | `alacritty` |
| Rofi | `rofi` |
| Nemo 文件管理器 | `nemo` |

### 自定义快捷键

如需修改快捷键，编辑对应窗口管理器的配置文件：

- **Hyprland**：`home/common/hyprland.nix`（`keybinds` 与 `settings.windowrulev2`），系统级启用位于 `modules/desktops/hyprland.nix`
- **Niri**：`home/common/niri.nix`（`settings.keybindings`），系统级启用位于 `modules/desktops/niri.nix`

修改后执行 `home-manager switch --flake .#<username>@<hostname>` 生效。
