# HL4W NixOS Configuration - 快捷键参考

**Version: v0.0.5**

本文档详细说明 Hyprland 和 Niri 窗口管理器的快捷键配置。

---

## Hyprland 快捷键

### 基础操作

| 快捷键 | 功能 |
|--------|------|
| `Super + Q` | 关闭活动窗口 |
| `Super + E` | 打开文件管理器（Nemo） |
| `Super + R` | 打开应用启动器（Rofi） |
| `Super + Return` | 打开终端（Foot） |
| `Super + C` | 打开 VS Code |
| `Super + P` | 打开电源菜单（Rofi） |

### 窗口焦点移动

| 快捷键 | 功能 |
|--------|------|
| `Super + H` | 焦点左移 |
| `Super + J` | 焦点下移 |
| `Super + K` | 焦点上移 |
| `Super + L` | 焦点右移 |

### 窗口大小调整

| 快捷键 | 功能 |
|--------|------|
| `Super + Shift + H` | 窗口缩小（左） |
| `Super + Shift + J` | 窗口扩大（下） |
| `Super + Shift + K` | 窗口缩小（上） |
| `Super + Shift + L` | 窗口扩大（右） |

### 工作区操作

| 快捷键 | 功能 |
|--------|------|
| `Super + 1` | 切换到工作区 1 |
| `Super + 2` | 切换到工作区 2 |
| `Super + 3` | 切换到工作区 3 |
| `Super + 4` | 切换到工作区 4 |
| `Super + 5` | 切换到工作区 5 |
| `Super + Shift + 1` | 移动窗口到工作区 1 |
| `Super + Shift + 2` | 移动窗口到工作区 2 |
| `Super + Shift + 3` | 移动窗口到工作区 3 |
| `Super + Shift + 4` | 移动窗口到工作区 4 |
| `Super + Shift + 5` | 移动窗口到工作区 5 |

### 窗口状态

| 快捷键 | 功能 |
|--------|------|
| `Super + F` | 切换浮动模式 |
| `Super + Full` | 全屏 |
| `Super + Shift + F` | 交换窗口位置 |
| `Alt + Shift + F` | 伪全屏 |

### 鼠标绑定

| 鼠标按钮 | 功能 |
|----------|------|
| 左键 | 移动窗口 |
| 中键 | 调整窗口大小 |
| 右键 | 切换浮动模式 |
| 侧键后（8） | 传递给应用程序处理（后退） |
| 侧键前（9） | 传递给应用程序处理（前进） |

---

## Niri 快捷键

### 基础操作

| 快捷键 | 功能 |
|--------|------|
| `Super` | 打开应用启动器（Rofi） |
| `Super + Return` | 打开终端（Foot） |
| `Super + E` | 打开文件管理器（Nemo） |
| `Super + W` | 关闭窗口 |
| `Super + Shift + Q` | 退出 Niri |

---

## 快捷键说明

### Super 键

在本配置中，`Super` 键通常指 **Windows 键** 或 **Command 键**（macOS 键盘）。

### 布局切换

- 键盘布局切换：`Alt + Shift`
- 支持英文（US）和中文（CN）两种布局

### 浮动窗口规则

以下应用默认以浮动模式打开：

- Kitty 终端
- Alacritty 终端
- Rofi（应用启动器、电源菜单）
- Nemo 文件管理器

---

## 自定义快捷键

如需修改快捷键，编辑对应窗口管理器的配置文件：

- Hyprland: `modules/desktops/hyprland.nix`
- Niri: `modules/desktops/niri.nix`