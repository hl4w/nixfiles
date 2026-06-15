# HL4W FAQ

## 通用

### 这是什么配置？

HL4W 是一个 NixOS 26.05 配置仓库，使用 Nix Flakes 和 Home Manager 在多台机器上管理系统和用户配置。它支持 Hyprland 和 Niri 窗口管理器，仅使用 Wayland 显示。

### 为什么使用 Flakes？

Flakes 提供可重现的构建、更好的依赖管理，以及更清晰的 Nix 配置结构。

### 支持哪些窗口管理器？

- **Hyprland**: 动态平铺窗口管理器，使用 Lua 配置（通过 hyprnix）
- **Niri**: 现代可滚动平铺窗口管理器，推荐用于笔记本电脑

### 有哪些桌面 Shell 可用？

- **DMS-Shell**: 轻量级显示管理器 Shell
- **Noctalia-Shell**: 现代化桌面集成 Shell

## 安装

### 如何使用此配置安装 NixOS？

**方法 1：使用 install.sh（推荐）**

```bash
# 克隆仓库
git clone <repo-url>
cd nixfiles26

# 运行安装脚本
chmod +x scripts/install.sh
./scripts/install.sh
```

脚本将引导您完成：
1. 输入用户名、主机名、Git 信息
2. 选择主机类型（Desktop/Laptop/Server）
3. 选择窗口管理器（Hyprland/Niri）
4. 选择桌面 Shell（DMS-Shell/Noctalia-Shell）
5. 生成硬件配置并部署

**方法 2：手动安装**

1. 从 NixOS 安装介质启动
2. 分区磁盘
3. 挂载分区
4. 克隆此仓库
5. 生成硬件配置：`nixos-generate-config --show-hardware-config > hosts/your-host/hardware-configuration.nix`
6. 运行：`nixos-install --flake .#your-host`

### 如何添加新主机？

请参阅 `docs/architecture.md` 获取详细说明，或直接运行 `./scripts/install.sh`。

## 配置

### 如何自定义 Shell？

编辑 `home/common/shell.nix` 进行共享 Shell 配置，或在 `home/hosts/` 中创建主机特定的覆盖配置。

### 如何添加包？

| 包类型 | 位置 | 示例 |
|--------|------|------|
| 系统包 | `modules/system/default.nix` | git, wget, curl, tmux, zsh |
| 用户包 | `home/common/cli.nix` | fastfetch, btop, eza, bat, fzf, fd, ripgrep, yazi, zoxide, dust, duf, tokei, hyperfine, procs |
| 桌面包 | `home/common/apps.nix` | rofi, nemo, nemo-extensions, evince, eog, alacritty/kitty/foot（默认 foot）, vlc |
| 开发包 | `home/common/dev-lsp.nix` | clangd, clang-tools, cmake, ninja, gdb, lldb, go, gopls, python3, pyright, rustc, rust-analyzer, rustfmt, cargo |
| 办公包 | `home/common/apps.nix` | wps-office-cn, nextcloud-client |

### 如何使用 Yazi 文件管理器？

Yazi 是一个快速的终端文件管理器，已在 `home/common/cli.nix` 中配置：

```bash
# 启动 Yazi
yazi

# 基本操作
# 方向键 / hjkl: 导航
# Enter: 打开文件/目录
# q: 退出
# : 打开命令面板
# Ctrl+G: 打开 shell（支持 zoxide 跳转）
```

### 如何使用 Zoxide 智能导航？

Zoxide 已在 `home/common/cli.nix` 中配置：

```bash
# 跳转到包含关键字的目录
z <keyword>

# 交互式选择
zi

# 跳转到最近使用的目录
z -

# 添加目录到数据库
z ~/projects/my-project
```

### 什么是 Lix？

Lix 是 Nix 包管理器的高性能替代实现：

- **优势**: 比原生 Nix 更快（特别是 eval 和 fetch 操作，性能提升可达 2-3 倍）
- **兼容性**: 完全兼容 Nix 所有功能（flakes、nix-command、nix-shell 等）
- **性能**: 使用 C++ 重写，内存效率更高
- **配置**: 在 `modules/system/default.nix` 中通过 overlay 自动配置

验证安装：
```bash
nix --version
# 输出: nix (Lix, like Nix) 2.x.x
```

### 如何使用 dust 分析磁盘使用？

```bash
# 查看当前目录磁盘使用
dust

# 查看指定目录
dust ~/projects

# 显示文件大小
dust -s

# 按大小排序
dust -X
```

### 如何使用 duf 查看磁盘空间？

```bash
# 查看所有磁盘
duf

# 查看指定设备
duf /dev/nvme0n1p2

# JSON 输出
duf --json
```

### 如何使用 tokei 统计代码？

```bash
# 统计当前目录代码
tokei

# 排除目录
tokei --exclude "node_modules"

# 输出 JSON 格式
tokei --json

# 只统计特定语言
tokei --types Rust,Go,Python
```

### 如何使用 hyperfine 测试命令性能？

```bash
# 比较两个命令
hyperfine "ls -la" "eza -la"

# 多次运行
hyperfine --runs 10 "my-command"

# 预热运行
hyperfine --warmup 3 "my-command"
```

### 如何使用 procs 查看进程？

```bash
# 查看所有进程
procs

# 搜索进程
procs firefox

# 树形视图
procs --tree

# 详细信息
procs -l
```

### 如何配置 Hyprland？

编辑 `modules/desktops/hyprland.nix` 进行系统级配置。Hyprland 使用由 hyprnix 管理的 Lua 语法。

### 如何配置 Niri？

编辑 `modules/desktops/niri.nix` 进行系统级配置。

### 如何配置输入法（中文）？

配置使用 Fcitx5 + RIME 搭配 oh-my-rime 预设：
- 系统级：`modules/input-method/default.nix`
- 用户级：`home/common/input.nix`

### 如何使用壁纸自动取色功能？

本配置包含使用 `pywal` 的壁纸自动取色系统：

```bash
# 设置指定壁纸并应用颜色
wp-color -s my-wallpaper.png

# 使用默认壁纸（default.jpg）
wp-color -s

# 从 ~/.wallpapers/ 随机选择壁纸
wp-random

# 应用当前颜色（不更换壁纸）
wp-apply

# 列出可用壁纸
wp-list
```

颜色会自动从壁纸提取并应用到：
- 终端（alacritty、kitty、foot）
- Shell 提示符（Starship）
- Neovim/Emacs 编辑器
- Noctalia-Shell 和 DMS-Shell

**自动监听器**：系统会自动监控壁纸变化。当您通过 Noctalia-Shell/DMS-Shell GUI 选择壁纸时，颜色会自动更新。

### 壁纸颜色不生效？

确保：
- `pywal` 已安装（包含在 `unified-theme.nix` 中）
- 壁纸目录存在：`~/.wallpapers`（自动创建）
- 颜色已在 Shell 中加载：`source ~/.cache/wal/colors.sh`
- 壁纸监听器服务正在运行：`systemctl --user status wallpaper-watcher`

### 如何使用日夜主题切换？

统一主题支持自动日夜主题切换：

```bash
# 根据时间自动切换（浅色：6:00-18:00，深色：其他时间）
theme-auto

# 手动切换到深色主题
theme-dark

# 手动切换到浅色主题
theme-light
```

### 如何配置日夜主题切换？

在主机配置中添加以下内容（`hosts/<hostname>/configuration.nix`）：

```nix
desktop.unified-theme = {
  themeMode = "auto";    # dark/light/auto
  dayStart = 6;          # 白天开始时间
  nightStart = 18;       # 夜晚开始时间
};
```

### 主题切换不工作？

确保：
- `unified-theme.nix` 已在主机配置中导入
- 命令可用：`which theme-auto theme-dark theme-light`
- 主题脚本在 `environment.systemPackages` 中

### 如何配置中国镜像？

镜像在 `flake.nix`（nixConfig）和 `modules/system/default.nix`（nix.settings）中配置：

```nix
substituters = [
  "https://mirrors.ustc.edu.cn/nix-channels/store"  # 中科大（推荐）
  "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"  # 清华
  "https://mirrors.bfsu.edu.cn/nix-channels/store"  # 北外
  "https://cache.nixos.org"  # 官方（备用）
];
```

## 故障排除

### Flake 构建失败

检查错误消息以查找缺失的依赖或语法错误。运行 `nix flake check` 验证 flake。

### Home Manager 切换失败

检查 `home-manager switch --flake .#user@host` 输出获取详细错误消息。

### Hyprland 无法启动

确保：
- 图形驱动已正确安装
- `xdg-desktop-portal-hyprland` 在 `environment.systemPackages` 中
- SDDM 以 Wayland 模式运行
- 日志位于 `~/.local/share/hyprland/`

### Niri 无法启动

确保：
- Wayland 会话已正确配置
- SDDM 使用正确的会话文件
- `xdg-desktop-portal-niri` 已安装

### 没有声音

检查：
- PipeWire 是否已启用：`systemctl --user status pipewire`
- 选择了正确的音频设备
- 用户在 `audio` 组中

### SDDM 无法启动

检查：
- 显示管理器已启用：`services.sddm.enable = true`
- Wayland 模式已启用：`services.sddm.wayland.enable = true`
- 图形驱动已正确配置
- `qt6Packages.qtwayland` 已安装

### kdePackages/qt6Packages 包未找到

在 NixOS 26.05 中，一些 Qt 包需要特定前缀：

```nix
# 正确
qt6Packages.qtwayland
kdePackages.polkit-kde-agent-1
qt6Packages.fcitx5-configtool
qt6Packages.fcitx5-chinese-addons

# 错误
qtwayland
polkit-kde-agent
fcitx5-configtool
fcitx5-chinese-addons
```

### 二进制下载速度慢

确保在 `flake.nix` 和 `modules/system/default.nix` 中配置了中国镜像。使用以下命令检查：

```bash
nix show-config | grep substituters
```

## 性能

### 如何优化性能？

- 为桌面启用 `services.powerManagement.cpuFreqGovernor = "performance"`
- 使用 `boot.kernelParams` 进行硬件特定优化
- 根据 CPU 核心数添加 `nix.settings.max-jobs`

### 如何优化 Nix 构建速度？

- 使用中国镜像加快二进制下载
- 启用 `nix.settings.auto-optimise-store = true`
- 增加 `nix.settings.max-jobs` 进行并行构建

## 安全

### 如何管理密钥？

使用 `agenix` 加密密钥。有关详细信息，请参阅 `secrets/README.md`。

### 如何启用防火墙？

防火墙在 `modules/services/security.nix` 中默认启用。根据需要添加允许的端口。

### 如何配置 UEFI 启动？

UEFI 启动与 systemd-boot 在 `modules/boot/default.nix` 中配置：
- 默认保留 3 个启动项
- 使用 systemd-boot 而不是 GRUB

## 更新

### 如何更新系统？

```bash
# 更新 flake 输入
nix flake update

# 重建系统
sudo nixos-rebuild switch --flake .#hostname

# 或使用更新脚本
./scripts/update.sh
```

### 如何清理旧代次？

```bash
# 清理用户代次
nix-collect-garbage -d

# 清理系统代次
sudo nix-collect-garbage -d

# 或使用清理脚本
./scripts/clean.sh
```