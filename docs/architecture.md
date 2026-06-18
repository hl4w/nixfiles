# HL4W 架构说明

**Version: v0.0.5**

## 概述

HL4W NixOS 配置采用模块化、主机特定的结构，允许从单个仓库管理多台机器。基于 NixOS 26.05，支持 Hyprland/Niri 窗口管理器，使用 Lix 作为高性能 Nix 实现。

## 目录结构

```
.
├── hosts/                 # 主机特定配置（系统级）
│   ├── common/           # 共享硬件和桌面优化配置
│   │   ├── default.nix        # 默认导入配置
│   │   ├── desktop-common.nix # 桌面通用配置（用户组等）
│   │   └── hardware-common.nix # 硬件通用配置（GPU、音频基础）
│   ├── desktop/          # 桌面配置（由 install.sh 生成）
│   │   └── configuration.nix  # 系统级配置
│   ├── laptop/           # 笔记本配置（由 install.sh 生成）
│   │   └── configuration.nix  # 系统级配置
│   └── server/           # 服务器配置（由 install.sh 生成）
│       └── configuration.nix
├── modules/              # 可复用的系统模块
│   ├── boot/             # 启动相关模块（UEFI、systemd-boot）
│   │   ├── default.nix
│   │   └── plymouth.nix
│   ├── hardware/         # 硬件特定模块
│   │   ├── bluetooth.nix
│   │   ├── firmware.nix
│   │   ├── mouse.nix       # 鼠标侧键配置说明
│   │   ├── nvidia.nix
│   │   └── sound.nix       # 音频配置
│   ├── desktops/         # 桌面环境配置
│   │   ├── desktop.nix    # 桌面配置模块（动态选择窗口管理器和 shell）
│   │   ├── hyprland.nix   # Hyprland 窗口管理器（通过 hyprnix 使用 Lua 配置）
│   │   ├── niri.nix       # Niri 窗口管理器
│   │   ├── sddm.nix       # SDDM（仅 Wayland）
│   │   ├── shell-dms.nix  # DMS-Shell（轻量级）
│   │   ├── shell-noctalia.nix   # Noctalia-Shell（现代化）
│   │   └── unified-theme.nix    # GTK/Qt/Hyprland/Niri/Shell 主题，支持日夜切换
│   ├── system/           # 系统基础配置
│   │   ├── default.nix   # 基础系统配置、用户、包、Nix 配置
│   │   └── fonts.nix     # 字体配置（Noto CJK、思源、文泉驿）、WPS Office CN 字体别名
│   ├── services/         # 服务配置
│   │   ├── default.nix   # 服务模块入口
│   │   ├── network.nix   # NetworkManager、网络栈
│   │   ├── security.nix  # 防火墙、安全设置
│   │   └── virtualisation.nix # Docker、Libvirt
│   └── input-method/     # 输入法配置
│       └── default.nix   # Fcitx5 + RIME 输入法（仅 Wayland）
├── home/                 # Home Manager 配置
│   ├── common/           # 共享用户配置
│   │   ├── shell.nix     # Zsh、Starship
│   │   ├── editor.nix    # Neovim、Emacs
│   │   ├── input.nix     # Fcitx5 + RIME（oh-my-rime）
│   │   ├── cli.nix       # eza、bat、fd、rg、fzf、yazi（zoxide 集成）、fastfetch、btop、vlc
│   │   ├── apps.nix      # GUI 应用
│   │   ├── dev-lsp.nix   # LSP 服务器（包括 C/C++）
│   │   ├── git.nix       # Git 配置
│   │   └── wallpaper-watcher.nix  # 壁纸监听器用户服务
│   └── hosts/            # 主机特定用户配置（用户级）
│       ├── desktop/       # 桌面用户配置
│       │   └── default.nix  # 桌面特定软件包（游戏、创作工具）
│       ├── laptop/        # 笔记本用户配置
│       │   └── default.nix  # 笔记本特定软件包（VPN、电源管理）
│       ├── server/        # 服务器用户配置
│       │   └── default.nix  # 服务器特定配置
│       ├── desktop.nix    # 桌面入口（导入 common + desktop/default.nix）
│       ├── laptop.nix     # 笔记本入口（导入 common + laptop/default.nix）
│       └── server.nix     # 服务器入口（导入 common + server/default.nix）
├── secrets/              # 加密密钥（agenix）
│   ├── example.age       # 示例密钥文件
│   └── README.md         # 密钥管理说明
├── scripts/              # 实用脚本
│   ├── install.sh        # 交互式安装脚本
│   ├── install_en.sh     # 安装脚本（英文版本）
│   ├── update.sh         # 更新 flake 并重建
│   ├── update_en.sh      # 更新脚本（英文版本）
│   ├── clean.sh          # 清理 Nix store
│   ├── clean_en.sh       # 清理脚本（英文版本）
│   ├── setup-disk.sh     # 磁盘分区脚本
│   ├── setup-disk_en.sh  # 磁盘分区脚本（英文版本）
│   ├── setup-direnv.sh   # direnv 设置脚本
│   ├── setup-direnv_en.sh # direnv 设置脚本（英文版本）
│   ├── wallpaper-color.sh # 壁纸自动取色脚本
│   ├── wallpaper-color_en.sh # 壁纸取色脚本（英文版本）
│   ├── wallpaper-watcher.sh # 壁纸变化监听器
│   └── wallpaper-watcher_en.sh # 壁纸监听器（英文版本）
├── wallpapers/           # 壁纸图片目录
│   ├── default.jpg       # 默认壁纸（中式深色主题）
│   └── README.md         # 壁纸说明及完整壁纸仓库地址
├── templates/            # 主机模板
│   └── host-template/
│       └── configuration.nix
├── docs/                 # 文档
│   ├── architecture.md   # 架构说明
│   ├── architecture_en.md # 架构说明（英文）
│   ├── CHANGELOG.md      # 变更日志
│   ├── CHANGELOG_EN.md   # 变更日志（英文）
│   ├── faq.md            # 常见问题
│   ├── faq_en.md         # 常见问题（英文）
│   ├── migration.md      # 迁移指南
│   ├── migration_en.md   # 迁移指南（英文）
│   ├── shortcuts.md      # 快捷键参考
│   └── shortcuts_en.md   # 快捷键参考（英文）
├── flake.nix             # Flake 入口点
├── flake.lock            # 锁定版本
├── README.md             # 项目概述（中文）
├── README_en.md          # 项目概述（英文）
└── LICENSE               # 许可证
```

## 模块结构

### 系统模块 (`modules/`)

| 模块 | 描述 |
|------|------|
| `system/default.nix` | 基础系统配置（包、时区、区域设置、带中国镜像的 Nix 设置） |
| `services/default.nix` | 服务模块入口（导入网络、安全、虚拟化） |
| `services/network.nix` | 网络配置（NetworkManager、DNS） |
| `services/security.nix` | 安全设置（防火墙、sudo、faillock） |
| `services/virtualisation.nix` | Docker 和 Libvirt 配置（可选） |
| `boot/default.nix` | UEFI 启动，使用 systemd-boot，保留 3 个启动项，静默启动参数 |
| `boot/plymouth.nix` | Plymouth 启动动画配置（配合 systemd initrd） |
| `input-method/default.nix` | Fcitx5 + RIME 输入法（仅 Wayland） |
| `desktops/desktop.nix` | 桌面环境配置模块（动态选择窗口管理器和桌面 shell） |
| `desktops/hyprland.nix` | Hyprland（通过 hyprnix 使用 Lua 语法） |
| `desktops/niri.nix` | Niri 窗口管理器 |
| `desktops/sddm.nix` | SDDM（仅 Wayland 模式，支持 Xwayland） |
| `desktops/shell-dms.nix` | DMS-Shell 依赖 |
| `desktops/shell-noctalia.nix` | Noctalia-Shell 依赖 |
| `desktops/unified-theme.nix` | GTK/Qt/Hyprland/Niri/Shell 主题（Adwaita Dark/Light）、图标（Papirus）、pywal 集成、日夜切换、桌面环境标识动态切换 |
| `system/fonts.nix` | 系统字体配置（Noto CJK、思源、文泉驿）、WPS Office CN 字体别名映射 |
| `hardware/bluetooth.nix` | 蓝牙设备配置 |
| `hardware/firmware.nix` | 额外固件支持（如 Intel WiFi、音频等） |
| `hardware/mouse.nix` | 鼠标配置（侧键支持） |
| `hardware/nvidia.nix` | NVIDIA 显卡驱动配置 |
| `hardware/sound.nix` | 音频系统配置（rtkit + PipeWire + PulseAudio 兼容性） |

### Home Manager 模块 (`home/common/`)

| 模块 | 描述 |
|------|------|
| `shell.nix` | Bash + Zsh + Starship 提示符（支持 pywal 动态配色） |
| `editor.nix` | Neovim、Emacs（配置了 LSP 服务器：nil_ls、clangd、gopls、pyright、rust_analyzer） |
| `input.nix` | Fcitx5 + RIME（oh-my-rime 配置） |
| `cli.nix` | CLI 工具集：eza、bat、fd、rg、fzf、yazi（终端文件管理器，支持 zoxide 集成）、zoxide（智能目录导航）、fastfetch、btop、dust、duf、tokei、hyperfine、procs、starship |
| `apps.nix` | GUI 应用（浏览器、办公、媒体） |
| `dev-lsp.nix` | 开发工具和 LSP 服务器（C/C++: clangd/clang-tools/cmake/ninja/gdb/lldb；Go: go/gopls；Python: python3/pyright；Rust: rustc/rust-analyzer/rustfmt/cargo） |
| `git.nix` | Git 全局配置 |
| `wallpaper-watcher.nix` | 壁纸变化监听器用户服务（自动更新配色） |

### 文档 (`docs/`)

| 文档 | 描述 |
|------|------|
| `architecture.md` | 架构说明 |
| `architecture_en.md` | 架构说明（英文） |
| `CHANGELOG.md` | 变更日志 |
| `CHANGELOG_EN.md` | 变更日志（英文） |
| `faq.md` | 常见问题 |
| `faq_en.md` | 常见问题（英文） |
| `migration.md` | 迁移指南 |
| `migration_en.md` | 迁移指南（英文） |
| `shortcuts.md` | Hyprland/Niri 快捷键参考 |
| `shortcuts_en.md` | Hyprland/Niri 快捷键参考（英文） |

## Flake 结构

`flake.nix` 是项目的入口配置文件，定义了完整的构建环境：

### 输入源 (inputs)

| 输入 | URL | 说明 |
|------|-----|------|
| `nixpkgs` | `github:NixOS/nixpkgs/nixos-26.05` | NixOS 26.05 稳定版 |
| `home-manager` | `github:nix-community/home-manager/release-26.05` | Home Manager 与 nixpkgs 版本同步 |
| `hyprnix` | `github:hyprwm/hyprnix/main` | Hyprland 工具链，用于管理 Hyprland 配置 |

### 全局配置 (nixConfig)

- **二进制缓存源**: 配置中国镜像加速下载
  - 中科大镜像（主）: `https://mirrors.ustc.edu.cn/nix-channels/store`
  - 清华镜像: `https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store`
  - 北外镜像: `https://mirrors.bfsu.edu.cn/nix-channels/store`
  - 官方源（备用）: `https://cache.nixos.org`
- **实验性功能**: 启用 `nix-command` 和 `flakes`
- **存储优化**: 启用 `auto-optimise-store`

### 主机配置生成器 (mkHost)

`mkHost` 函数用于生成统一的主机配置：

```nix
mkHost = name: nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./hosts/${name}/configuration.nix  # 主机特定配置
    home-manager.nixosModules.home-manager
    {
      home-manager.users.${USERNAME} = import ./home/hosts/${name}.nix;
    }
  ];
  specialArgs = {
    inherit inputs;
    nixSubstituters = substituters;
    nixTrustedPublicKeys = trusted-public-keys;
  };
};
```

### 输出 (outputs)

- **nixosConfigurations**: 主机配置输出（由安装脚本动态生成）

### 添加新主机

**方法 1：使用 install.sh（推荐）**

```bash
./scripts/install.sh
```

脚本将引导您完成：
1. 输入用户名、主机名、Git 信息
2. 选择主机类型（Desktop/Laptop/Server）
3. 选择窗口管理器（Hyprland/Niri）
4. 选择桌面 Shell（DMS-Shell/Noctalia-Shell）
5. 选择 polkit 代理（KDE/Hyprland）
6. 自动生成配置文件

**方法 2：手动**

1. 在 `hosts/` 中创建新目录
2. 添加 `configuration.nix`（参考 `templates/host-template/`）
3. 使用 `nixos-generate-config --show-hardware-config > hosts/your-host/hardware-configuration.nix` 生成 `hardware-configuration.nix`
4. 在 `flake.nix` 的 `nixosConfigurations` 下添加主机
5. 在 `home/hosts/` 中创建相应的用户配置

## 配置流程

1. `flake.nix` → 定义输入、输出和中国镜像
2. 主机 `configuration.nix` → 导入系统模块
3. 系统模块 → 配置系统服务和包
4. Home Manager → 导入用户模块
5. 用户模块 → 配置用户特定设置

## 主要功能

### 中国镜像配置

二进制包从中国镜像下载以提高速度：

```nix
nixConfig = {
  substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"  # 中科大（推荐）
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"  # 清华
    "https://mirrors.bfsu.edu.cn/nix-channels/store"  # 北外
    "https://cache.nixos.org"  # 官方（备用）
  ];
};
```

### 壁纸自动取色系统

本配置包含使用 `pywal` 的壁纸自动取色系统：

- **功能**: 从壁纸提取颜色并动态应用到：
  - 终端（alacritty、kitty、foot）
  - Shell 提示符（Starship）
  - Neovim/Emacs 编辑器
  - GTK/Qt 应用

- **脚本**:
  - `scripts/wallpaper-color.sh`: 壁纸颜色提取主脚本
  - `wp-color`: 设置指定壁纸并应用颜色
  - `wp-random`: 从 `~/.wallpapers/` 随机选择壁纸
  - `wp-apply`: 应用当前颜色（不更换壁纸）
  - `wp-list`: 列出可用壁纸

- **集成**:
  - 颜色存储在 `~/.cache/wal/`
  - 在 `home/common/shell.nix` 中自动加载
  - 与 DMS-Shell 和 Noctalia-Shell 无缝协作

### 日夜主题切换

统一主题系统支持自动日夜主题切换：

- **功能**: 根据时间自动在浅色和深色主题之间切换
  - 日间模式（6:00-18:00）：Adwaita（浅色）、Papirus 图标
  - 夜间模式（18:00-6:00）：Adwaita-dark、Papirus-Dark 图标

- **命令**:
  - `theme-auto`: 根据当前时间自动切换
  - `theme-dark`: 强制深色模式
  - `theme-light`: 强制浅色模式

- **配置**（在主机配置中）：
  ```nix
  desktop.unified-theme = {
    themeMode = "auto";    # dark/light/auto
    dayStart = 6;          # 白天开始时间
    nightStart = 18;       # 夜晚开始时间
  };
  ```

- **实现**:
  - 由 `modules/desktops/unified-theme.nix` 管理
  - 通过 `pkgs.writeScriptBin` 创建脚本
  - 主题应用到 GTK、Qt、Shell 和 SDDM

### 桌面配置模块

桌面配置模块 `modules/desktops/desktop.nix` 支持动态选择窗口管理器、桌面 shell 和 polkit 代理：

- **配置选项**:
  ```nix
  desktop = {
    windowManager = "hyprland";  # 可选: "hyprland" 或 "niri"
    shell = "dms";               # 可选: "dms" 或 "noctalia"
    enableInputMethod = true;     # 是否启用输入法
    polkitAgent = "kde";         # 可选: "kde" (polkit-kde-agent-1) 或 "hyprland" (hyprpolkitagent)
  };
  ```

- **窗口管理器与 Shell 组合支持**:
  | 窗口管理器 | 桌面 Shell | 说明 |
  |-----------|-----------|------|
  | hyprland | dms | 轻量级组合，性能优先 |
  | hyprland | noctalia | 现代化集成体验 |
  | niri | dms | 轻量级组合，适合笔记本 |
  | niri | noctalia | 现代平铺 + 集成 Shell |

- **polkit 代理选择**:
  | 选项 | 包 | 说明 |
  |------|-----|------|
  | kde | `kdePackages.polkit-kde-agent-1` | KDE 风格的权限代理，功能完整 |
  | hyprland | `hyprpolkitagent` | Hyprland 原生代理，更轻量 |

- **Qt6 主题工具**:
  - `qt6Packages.adwaita-qt`: Qt6 Adwaita 主题
  - `adwaita-qt`: Qt5 Adwaita 主题（兼容性）
  - `gnome.adwaita-icon-theme`: Adwaita 图标主题
  - `gnome.gnome-themes-extra`: GTK 主题支持

- **实现**: 根据配置动态导入相应模块，无需手动修改 imports

### 壁纸自动取色（pywal）

配置使用 `pywal` 从壁纸提取颜色并应用到各种应用：

- **命令**:
  - `wp-color -s <wallpaper>`: 设置壁纸并应用颜色
  - `wp-random`: 从壁纸目录随机选择
  - `wp-apply`: 应用当前颜色（不更换壁纸）
  - `wp-list`: 列出可用壁纸

- **壁纸目录**:
  - 项目: `wallpapers/`
  - 用户: `~/.wallpapers/`（从项目自动同步）
  - 默认: `default.jpg`（中国风雄伟山河深色调）

- **自动监听器**:
  - 后台服务 (`wallpaper-watcher`) 监控壁纸变化
  - 当通过 Shell GUI 更改壁纸时自动触发配色更新

- **应用范围**:
  - 终端（Alacritty、Kitty、Foot）
  - Starship 提示符
  - Neovim 编辑器
  - Noctalia-Shell 和 DMS-Shell

- **实现**:
  - 脚本: `scripts/wallpaper-color.sh`
  - 监听器: `scripts/wallpaper-watcher.sh`
  - 用户服务: `home/common/wallpaper-watcher.nix`

### 仅支持 Wayland

本配置仅支持 Wayland/Xwayland，不支持纯 X11：

- SDDM 以 Wayland 模式运行
- 启用 Xwayland 以兼容 X11 应用
- 移除 Xorg 工具，使用 Wayland 原生工具（wlr-randr）

### 包分类

| 级别 | 包 | 位置 |
|------|------|------|
| 系统 | git、wget、curl、nil、tmux、zsh、tree、highlight、nixpkgs-fmt | `modules/system/default.nix` |
| 用户 | fastfetch、btop、eza、bat、fzf、fd、ripgrep、yazi、zoxide、dust、duf、tokei、hyperfine、procs | `home/common/cli.nix` |
| 桌面 | rofi、nemo、nemo-extensions、evince、eog、alacritty/kitty/foot（默认 foot）、pywal、vlc | `home/common/apps.nix` |
| 开发 | clangd、clang-tools、cmake、ninja、gdb、lldb、go、gopls、python3、pyright、rustc、rust-analyzer、rustfmt、cargo | `home/common/dev-lsp.nix` |
| 办公 | wps-office-cn、nextcloud-client | `home/common/apps.nix` |

### 字体配置

本配置包含完善的中文字体支持，专为 WPS Office CN 优化：

- **字体模块**: `modules/system/fonts.nix`
- **默认字体**: Noto Sans（英文），通过 FontConfig fallback 支持中文
- **基础字体包**:
  - `noto-fonts` - Noto 基础字体
  - `noto-fonts-emoji` - Noto Emoji 字体
  - `noto-fonts-color-emoji` - Noto 彩色 Emoji 字体
- **中文字体包**:
  - `noto-fonts-cjk` - Noto CJK 中日韩字体
  - `source-han-sans` - 思源黑体
  - `source-han-serif` - 思源宋体
  - `source-han-mono` - 思源等宽
  - `wqy_microhei` - 文泉驿微米黑
  - `wqy_zenhei` - 文泉驿正黑
  - `wqy_bitmapfont` - 文泉驿点阵字体
- **编程字体包**:
  - `jetbrains-mono` - JetBrains Mono 等宽字体
  - `fira-code` - Fira Code 编程字体（连字支持）
  - `source-code-pro` - Source Code Pro 编程字体
  - `iosevka` - Iosevka 编程字体（高度可定制）
- **图标字体**:
  - `font-awesome` - Font Awesome 图标字体

- **字体别名映射**（WPS Office CN 兼容）:
  - SimSun → Noto Serif CJK SC
  - SimHei → Noto Sans CJK SC
  - Microsoft YaHei → Noto Sans CJK SC
  - KaiTi → Noto Serif CJK SC
  - FangSong → Noto Serif CJK SC
  - STSong/STHeiti/STKaiti/STFangsong → Noto Serif/Noto Sans CJK SC

- **WPS Office CN**: 中国版办公套件，默认包含中文字体，对国内常用格式兼容性更好

### 拼写检查器

系统级安装拼写检查支持：

- **拼写检查引擎**: `nuspell`（比 Hunspell 快 3 倍，完全兼容 Hunspell 词典格式）
- **英语词典**: `hunspellDicts.en-us`（美国）、`hunspellDicts.en-gb-ise`（英国）

> **注意**: Nuspell/Hunspell 不支持中文拼写检查，因为其分词机制基于空格和字母边界，无法处理中文连续字符。中文拼写检查建议使用 LanguageTool 或其他专门的中文分词工具。

### kdePackages/qt6Packages 前缀

在 NixOS 26.05 中，一些 Qt/KDE 包需要 `kdePackages` 或 `qt6Packages` 前缀：

- `qt6Packages.qtwayland`
- `qt6Packages.fcitx5-configtool`
- `qt6Packages.fcitx5-chinese-addons`
- `kdePackages.polkit-kde-agent-1`
- `qt6Packages.adwaita-qt`
- `qt6Packages.qtmultimedia`
- `qt6Packages.fcitx5-qt`

### Lix 高性能 Nix 实现

本配置使用 **Lix** 作为 Nix 包管理器的替代实现：

- **Lix 优势**:
  - 比原生 Nix 更快（特别是在 eval 和 fetch 场景）
  - 完全兼容 Nix 所有功能（flakes、nix-command 等）
  - 社区驱动，持续活跃开发
  - 使用 C++ 重写，性能更优

- **配置方式**:
  ```nix
  # 使用 Lix stable 版本
  nix.package = pkgs.lixPackageSets.stable.lix;
  ```

- **Overlay 配置**: 使用 `nixpkgs.overlays` 确保依赖 Nix 的工具（如 nixpkgs-review、nix-eval-jobs）也使用 Lix

- **验证安装**:
  ```bash
  nix --version
  # 输出: nix (Lix, like Nix) 2.x.x
  ```

### 鼠标侧键配置

本配置支持鼠标侧键（Button 8/9）在应用程序中实现后退/前进功能：

- **实现模块**: `modules/hardware/mouse.nix` 和 `modules/desktops/hyprland.nix`
- **处理策略**: 使用 `pass` 命令让鼠标事件传递给应用程序

- **鼠标按钮编号**:
  - Button 1: 左键
  - Button 2: 中键（滚轮按下）
  - Button 3: 右键
  - Button 4/5: 滚轮上下滚动
  - Button 6/7: 滚轮倾斜（部分鼠标）
  - Button 8/9: 侧键（后退/前进）

- **Hyprland 配置**:
  ```nix
  binds = {
    "mouse,1" = "movewindow";   # 左键移动窗口
    "mouse,2" = "resizewindow"; # 中键调整大小
    "mouse,3" = "togglefloating"; # 右键切换浮动
    "mouse,8" = "pass";         # 侧键后（后退）- 传递给应用程序
    "mouse,9" = "pass";         # 侧键前（前进）- 传递给应用程序
  };
  ```

- **支持的应用**:
  - Nemo 文件管理器：后退/前进目录
  - Firefox/Chrome 浏览器：后退/前进页面
  - 其他 GTK/Qt 应用

## 密钥管理

密钥使用 `agenix` 管理。加密文件存储在 `secrets/` 中，在部署时解密。

## 构建流程

### 初始安装

```bash
# 使用安装脚本进行初始安装
./scripts/install.sh
```

### 系统更新

安装完成后，如果修改了任何 Nix 模块，可以直接使用以下命令更新系统：

```bash
# 更新系统（修改 modules/ 目录后使用）
sudo nixos-rebuild switch --flake .#<hostname>

# 更新 Home Manager 用户配置（修改 home/ 目录后使用）
home-manager switch --flake .#<username>@<hostname>

# 更新 flake 输入（升级依赖版本如 nixpkgs）
nix flake update

# 使用脚本一键更新（包含 flake update 和系统重建）
./scripts/update.sh
```

### 验证与回滚

```bash
# 检查配置语法
nix flake check

# 测试构建（不部署）
nix build .#<hostname>

# 预览差异
nixos-rebuild dry-activate --flake .#<hostname>

# 回滚到上一个代次
sudo nixos-rebuild switch --rollback

# 清理旧代次
./scripts/clean.sh
```