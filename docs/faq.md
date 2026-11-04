# HL4W FAQ

## 通用

### 这是什么配置？

HL4W 是一个 NixOS 26.05 配置仓库，使用 Nix Flakes 和 Home Manager 在多台机器上管理系统和用户配置。它支持 Hyprland 和 Niri 窗口管理器，仅使用 Wayland 显示。

### 为什么使用 Flakes？

Flakes 提供可重现的构建、更好的依赖管理，以及更清晰的 Nix 配置结构。

### 支持哪些窗口管理器？

- **Hyprland**: 动态平铺窗口管理器，使用 hyprlang 配置（`configType = "hyprlang"`）
- **Niri**: 现代可滚动平铺窗口管理器，推荐用于笔记本电脑

### 有哪些桌面 Shell 可用？

- **DMS Shell**: 轻量级桌面 Shell（模块：`programs.dms-shell`，配置在 `shell-dms.nix`）
- **Noctalia Shell**: 现代化桌面集成 Shell（模块：`shell-noctalia.nix`）

两者均为 Wayland Shell，在主机配置中通过 `desktop.shell` 选项选择：

```nix
desktop.shell = "dms";     // 或 "noctalia"
```

## 安装

### 如何使用此配置安装 NixOS？

全新机器（从 NixOS ISO 启动）推荐运行磁盘安装脚本。`setup-disk.sh` 会在挂载目标磁盘后自动克隆仓库到 `/mnt/etc/nixos`，并以 `-y` 模式调用 `install.sh` 生成主机配置、`nix flake lock` 锁定依赖、`nixos-generate-config --root /mnt` 生成硬件配置，用户只需检查后执行 `nixos-install`：

```bash
# 已 clone 仓库时直接运行（脚本内部会再克隆到 /mnt/etc/nixos，覆盖旧仓库）
sudo ./scripts/setup-disk.sh <disk> <hostname> <username>

# 脚本完成后，cd 到 /mnt/etc/nixos 执行安装
cd /mnt/etc/nixos
sudo nixos-install --flake .#<hostname>
```

省略 `-T/-W/-S` 时，脚本会在交互终端中提示选择主机类型、窗口管理器与桌面 Shell（直接回车使用默认值 `desktop`/`hyprland`/`dms`）；使用 `-y` 或 stdin 非终端时直接采用默认值，不会阻塞。

已有 NixOS 系统时使用 `install.sh` 生成主机配置：

**方法 1：使用 install.sh（推荐）**

```bash
# 克隆仓库
# 国内用户推荐使用 Gitee 镜像：
git clone https://gitee.com/hl4w/nixfiles.git
# 国外用户使用 GitHub：
# git clone https://github.com/hl4w/nixfiles.git
cd nixfiles

# 首次运行前生成 flake.lock（包含 oh-my-rime 输入法框架）
nix flake update

# 运行安装脚本（交互模式下依次询问各配置项）
chmod +x scripts/install.sh
./scripts/install.sh
```

脚本将引导您完成：
1. 输入用户名、主机名、Git 信息
2. 选择主机类型（Desktop/Laptop/Server）
3. 选择窗口管理器（Hyprland/Niri）
4. 选择桌面 Shell（DMS Shell / Noctalia Shell）
5. 选择 polkit 代理（KDE/Hyprland）
6. 生成硬件配置并部署

非交互模式可传入参数，例如 `./scripts/install.sh -y -U john -H my-desktop -T desktop -W hyprland -S dms -P kde`（`-y` 为自动确认开关，`-N` 可单独指定 flake 配置名称；完整选项见 `./scripts/install.sh -h`）。

**方法 2：手动安装**

1. 从 NixOS 安装介质启动
2. 分区磁盘
3. 挂载分区
4. 克隆此仓库
5. 生成硬件配置：`nixos-generate-config --show-hardware-config > hosts/your-host/hardware-configuration.nix`
6. 运行：`nixos-install --flake .#your-host`

### 如何添加新主机？

请参阅 `docs/architecture.md` 获取详细说明，或直接运行 `./scripts/install.sh`。

### 如何重建 flake.lock？

flake.lock 锁定所有输入的版本（nixpkgs、home-manager、oh-my-rime 等）。以下场景需要重建：

- 首次 clone 仓库（仓库未提交 `flake.lock`）
- 修改了 flake.nix 的 inputs 列表
- 想更新某个输入到最新版本

```bash
# 全部更新
nix flake update

# 只更新特定输入
nix flake update nixpkgs
nix flake update home-manager

# 更新后验证
nix flake check --no-build
```

## 配置

### 如何自定义 Shell？

编辑 `home/common/shell.nix` 进行共享 Shell 配置，或在 `home/hosts/` 中创建主机特定的覆盖配置。

### 如何添加包？

| 包类型 | 位置 | 示例 |
|--------|------|------|
| 系统包 | `modules/system/default.nix` | git, wget, curl, tmux, zsh |
| 用户包 | `home/common/cli.nix` | fastfetch, btop, eza, bat, fzf, fd, ripgrep, yazi, zoxide, dust, duf, tokei, hyperfine, procs |
| 桌面包 | `home/common/apps.nix` | rofi, nemo, nemo-extensions, evince, loupe, alacritty/kitty/foot（默认 foot）, vlc |
| 开发包 | `home/common/dev-lsp.nix` | clangd, clang-tools, cmake, ninja, gdb, lldb, go, gopls, python3, pyright, rustc, rust-analyzer, rustfmt, cargo |
| 办公包 | `home/common/apps.nix` | wps-office-cn, nextcloud-client |

### 如何添加自定义字体？

字体配置在 `modules/system/fonts.nix`，系统层统一管理：

```nix
fonts.packages = with pkgs; [
  noto-fonts-cjk-sans
  noto-fonts-cjk-serif
  noto-fonts-color-emoji
  source-han-sans-sc
  source-han-serif-sc
  wqy_microhei
  wqy_zenhei
  nerd-fonts.jetbrains-mono
  # 添加自定义字体：
  # fira-code
  # material-design-icons
];

# FontConfig  fallback 顺序
fonts.fontconfig.defaultFonts = {
  monospace = [ "JetBrainsMono Nerd Font" ];
  sans-serif = [ "Noto Sans CJK SC" ];
  serif = [ "Noto Serif CJK SC" ];
};
```

修改后执行 `sudo nixos-rebuild switch --flake .#<hostname>` 生效。

### CLI 工具速查

本项目预装的现代化 CLI 工具（均通过 `home/common/cli.nix` 配置）：

| 工具 | 用途 | 常用命令 |
|------|------|----------|
| `eza` | ls 替代品 | `eza -la`、`eza --tree=2` |
| `bat` | cat 替代品（语法高亮） | `bat file.md`、`bat --paging=never` |
| `fd` | 快速文件查找 | `fd pattern`、`fd -e rs` |
| `rg` | 快速内容搜索 | `rg keyword`、`rg -t python` |
| `fzf` | 模糊搜索 | `fzf`（Ctrl+R 历史搜索、Ctrl+T 文件搜索） |
| `yazi` | 终端文件管理器 | `yazi`（Ctrl+G 打开 shell + zoxide） |
| `zoxide` | 智能目录导航 | `z keyword`、`zi`（交互式）、`z -`（上一个） |
| `dust` | 磁盘使用分析 | `dust`、`dust -X`（按大小排序） |
| `duf` | 磁盘空间查看 | `duf`、`duf /dev/nvme0n1` |
| `tokei` | 代码统计 | `tokei`、`tokei --types Rust,Go` |
| `hyperfine` | 命令性能测试 | `hyperfine "ls" "eza"`、`hyperfine --runs 10 cmd` |
| `procs` | 增强版 ps | `procs`、`procs --tree`、`procs firefox` |
| `starship` | 跨 Shell 提示符 | 自动加载，配置在 `~/.config/starship.toml` |

### 什么是 Lix？

Lix 是 Nix 包管理器的高性能替代实现：

- **优势**: 比原生 Nix 更快（特别是 eval 和 fetch 操作，性能提升可达 2-3 倍）
- **兼容性**: 完全兼容 Nix 所有功能（flakes、nix-command、nix-shell 等）
- **配置**: 在 `modules/system/default.nix` 中通过 overlay 自动配置

验证安装：
```bash
nix --version
# 输出: nix (Lix, like Nix) 2.x.x
```

### 如何配置 Hyprland / Niri？

**Hyprland**：系统级启用位于 `modules/desktops/hyprland.nix`；按键绑定、窗口规则、gaps、动画等详细配置位于 `home/common/hyprland.nix`，使用 hyprlang 语法（`configType = "hyprlang"`）。

**Niri**：系统级启用位于 `modules/desktops/niri.nix`；按键绑定等详细配置位于 `home/common/niri.nix`。

快捷键完整列表见 `docs/shortcuts.md`。

### 如何配置 DMS Shell / Noctalia Shell？

两者都通过 NixOS 官方模块启用：

**DMS Shell**：`modules/desktops/shell-dms.nix` 使用 `programs.dms-shell.enable = true`，模块自带 `dms.service` systemd 用户单元，无需手动声明依赖或服务。

**Noctalia Shell**：`modules/desktops/shell-noctalia.nix` 使用 `programs.noctalia-shell.enable = true`，需额外确保 `services.upower.enable = true`（Noctalia v4 依赖）。

选择哪个 Shell 在主机配置中设置：

```nix
# hosts/<hostname>/configuration.nix
desktop.shell = "dms";       // 或 "noctalia"
```

### 如何配置输入法（中文）？

配置使用 Fcitx5 + RIME 搭配 oh-my-rime（薄荷拼音）预设：
- 系统级：`modules/input-method/default.nix`（Fcitx5 引擎、RIME 插件、Catppuccin 主题包）
- 用户级：`home/common/input.nix`（oh-my-rime 配置框架部署、方案列表、主题设置）

**oh-my-rime 配置机制**：
- oh-my-rime 作为 flake input 拉取，默认源为 CNB 官方镜像 `git+https://cnb.cool/Mintimate/rime/oh-my-rime`（国内访问稳定）；如需切回 GitHub 上游，启用 `flake.nix` 中 `inputs.oh-my-rime` 下已注释的 `github:Mintimate/oh-my-rime/main`（并注释掉镜像地址），然后执行 `nix flake update oh-my-rime`
- 通过 `home.file` 将 schema/dict/lua 文件符号链接到 `~/.local/share/fcitx5/rime/`
- 用 `default.custom.yaml` 覆盖 `schema_list` 指定启用的方案（默认 rime_mint、rime_mint_flypy、terra_pinyin、stroke）

**Catppuccin 主题切换**：
修改 `home/common/input.nix` 中 `classicui.conf` 的 `Theme` 值，格式为 `catppuccin-{flavor}-{accent}`：
- flavor：`latte`（亮）、`frappe`、`macchiato`、`mocha`（暗）
- accent：`rosewater`、`flamingo`、`pink`、`mauve`、`red`、`maroon`、`peach`、`yellow`、`green`、`teal`、`sky`、`sapphire`、`blue`、`lavender`
- 切换后执行 `fcitx5 -r` 重启 fcitx5 生效

### 如何使用壁纸自动取色功能？

本配置包含使用 `pywal` 的壁纸自动取色系统：

```bash
# 设置指定壁纸并应用颜色（-s 必须带壁纸名称或路径）
wp-color -s my-wallpaper.png

# 从 ~/.wallpapers/ 随机选择壁纸并取色（等价于 wp-color -d）
wp-random

# 应用当前配色（不更换壁纸，不重新取色）
wp-color -a

# 列出可用壁纸 / 查看当前配色
wp-color -l
wp-color -c
```

颜色会自动从壁纸提取并应用到终端（alacritty、kitty、foot）、Starship 提示符、Neovim 以及 DMS Shell / Noctalia Shell 的配色文件。

**自动监听器**：壁纸变化时自动取色（`home/common/wallpaper-watcher.nix` systemd 用户服务），可通过 `systemctl --user status wallpaper-watcher` 查看状态。

### 壁纸颜色不生效？

确保：
- `pywal` 已安装（包含在 `modules/desktops/unified-theme.nix` 中）
- 壁纸目录存在：`~/.wallpapers`（首次登录自动创建）
- 颜色已在 Shell 中加载：`source ~/.cache/wal/colors.sh`
- 壁纸监听器服务正在运行：`systemctl --user status wallpaper-watcher`
- 运行 `wal -R` 手动重新生成模板

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

**切换时间配置**（`hosts/<hostname>/configuration.nix`）：

```nix
desktop.unified-theme = {
  themeMode = "auto";    // dark / light / auto
  dayStart = 6;          // 白天开始时间（小时）
  nightStart = 18;       // 夜晚开始时间（小时）
};
```

### 如何配置中国镜像？

镜像在 `flake.nix`（nixConfig）和 `modules/system/default.nix`（nix.settings）中配置：

```nix
substituters = [
  "https://mirrors.ustc.edu.cn/nix-channels/store"  // 中科大（推荐）
  "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"  // 清华
  "https://mirrors.bfsu.edu.cn/nix-channels/store"  // 北外
  "https://cache.nixos.org"  // 官方（备用）
];
```

## 故障排除

### Flake 构建失败

检查错误消息以查找缺失的依赖或语法错误。运行以下命令定位问题：

```bash
# 快速求值检查（不编译）
nix flake check --no-build

# 查看完整错误栈
nix flake check --no-build 2>&1 | tail -50

# 测试构建单个主机
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

### Home Manager 切换失败

```bash
# 查看详细错误
home-manager switch --flake .#user@host 2>&1 | tail -30

# 启用 verbose 模式
home-manager switch --flake .#user@host --verbose
```

### Hyprland 无法启动

确保：
- 图形驱动已正确安装
- `xdg-desktop-portal-hyprland` 在系统包中
- SDDM 以 Wayland 模式运行
- 查看日志：`~/.local/share/hyprland/`
- 验证配置语法：`hyprctl config -h`（Hyprland 0.55+）

### Niri 无法启动

确保：
- Wayland 会话已正确配置
- SDDM 使用正确的会话文件
- `xdg-desktop-portal-niri` 已安装

### 没有声音

检查：
- PipeWire 状态：`systemctl --user status pipewire pipewire-pulse`
- 选择了正确的音频设备：`wpctl status`
- 用户在 `audio` 组中：`id | grep -o 'audio'`

### SDDM 无法启动

检查：
- 显示管理器已启用：`services.displayManager.sddm.enable = true`
- Wayland 模式已启用：`services.displayManager.sddm.wayland.enable = true`
- 图形驱动已正确配置
- `qt6Packages.qtwayland` 已安装

### kdePackages/qt6Packages 包未找到

在 NixOS 26.05 中，一些 Qt 包需要特定前缀：

```nix
// 正确
qt6Packages.qtwayland
kdePackages.polkit-kde-agent-1
qt6Packages.fcitx5-configtool
qt6Packages.fcitx5-chinese-addons

// 错误
qtwayland
polkit-kde-agent
fcitx5-configtool
fcitx5-chinese-addons
```

### Fcitx5 无法切换到中文

```bash
# 1. 验证 fcitx5 正在运行
fcitx5 -d

# 2. 查看 RIME 方案
rime_dict_manager list-schemas
fcitx5-diagnose

# 3. 确认环境变量（SDDM 启动器应自动设置）
echo $GTK_IM_MODULE   // 应为 fcitx
echo $QT_IM_MODULE    // 应为 fcitx
```

### 二进制下载速度慢

确保在 `flake.nix` 和 `modules/system/default.nix` 中配置了中国镜像。检查：

```bash
nix show-config | grep substituters
```

## 性能

### 如何优化性能？

- 桌面启用 `powerManagement.cpuFreqGovernor = "performance"`
- 使用 `boot.kernelParams` 进行硬件特定优化
- 根据 CPU 核心数设置 `nix.settings.max-jobs`
- 启用 `nix.settings.auto-optimise-store = true`

## 安全

### 如何管理密钥？

仓库预留 `secrets/` 目录用于存放加密密钥，但当前默认配置尚未集成 agenix 模块。如需使用，请先按 `secrets/README.md` 将 agenix 加入 flake 输入与主机配置。

### 如何启用防火墙？

防火墙在 `modules/services/security.nix` 中默认启用。根据需要添加允许的端口。

### 如何配置 UEFI 启动？

UEFI 启动与 systemd-boot 在 `modules/boot/default.nix` 中配置：
- 默认保留 3 个启动项
- 使用 systemd-boot 而不是 GRUB

## 更新

### 如何更新系统？

```bash
# 更新系统配置（修改 modules/ 后使用）
sudo nixos-rebuild switch --flake .#<hostname>

# 更新 Home Manager 用户配置（修改 home/ 后使用）
home-manager switch --flake .#<username>@<hostname>

# 更新 flake 输入（升级 nixpkgs 等依赖版本）
nix flake update

# 一键完成 flake update + 系统重建
./scripts/update.sh
```

### 修改模块后如何应用更改？

**修改系统模块** (`modules/` 目录)：
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

**修改用户配置** (`home/` 目录)：
```bash
home-manager switch --flake .#<username>@<hostname>
```

**同时更新系统和用户配置**：
```bash
./scripts/update.sh
```

### 如何在部署前验证配置？

```bash
# 检查配置语法（快速，不编译）
nix flake check --no-build

# 完整测试构建（不部署）
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# 预览将发生哪些变更
nixos-rebuild dry-activate --flake .#<hostname>
```

### 更新后如何回滚？

```bash
# 查看系统代
sudo nixos-rebuild list-generations

# 回滚到上一个系统代
sudo nixos-rebuild switch --rollback

# 指定回滚到某个系统代
sudo nixos-rebuild switch --generation <number>

# Home Manager 回滚
home-manager rollback
```

### 如何清理旧系统代？

```bash
# 清理用户代
nix-collect-garbage -d

# 清理系统代
sudo nix-collect-garbage -d

# 使用清理脚本（-a 全部、-s 仅 Nix store、-g 仅旧系统代）
./scripts/clean.sh -a
```
