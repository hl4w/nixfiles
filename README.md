# HL4W（Hack Linux for Workflow） - Nixfiles for NixOS

**Version: v0.0.6**

一套基于 NixOS 26.05 的现代化配置仓库，内置深度优化的 Hyprland & Niri 桌面套件，原生兼容 Noctalia & DMS Shell 桌面组件。使用 Nix Flakes + Home Manager 统一管理多台设备的系统与用户环境。

## 特性

- **Hyprland** / **Niri**: Wayland 窗口管理器 [(详细说明)](docs/architecture.md) [(快捷键)](docs/shortcuts.md)
- **模块化架构**: 清晰的目录结构与严格的系统层/用户层边界，易于扩展和维护 [(架构文档)](docs/architecture.md)
- **多主机支持**: 桌面、笔记本、服务器统一管理，按主机类型自动装配模块 [(架构文档)](docs/architecture.md)
- **一键装机**: `setup-disk.sh` 完成 GPT 分区、LUKS2 + LVM 加密、格式化、挂载与配置部署；`install.sh` 完成主机初始化 [(脚本说明](#脚本说明))
- **GPU 自动检测**: 安装时自动识别 NVIDIA/AMD/Intel 显卡，智能配置驱动和内核参数 [(架构文档)](docs/architecture.md)
- **主题统一**: GTK/Qt/Hyprland/Niri/Shell/SDDM/Fcitx5 统一配色（Catppuccin）[(架构文档)](docs/architecture.md)
- **壁纸自动取色**: 使用 pywal 从壁纸提取颜色，并由监听服务在壁纸变化时自动跟随 [(架构文档)](docs/architecture.md)
- **日夜主题切换**: 自动根据时间切换深浅风格 [(架构文档)](docs/architecture.md)
- **灵活桌面配置**: 支持动态选择窗口管理器（Hyprland/Niri）、桌面 Shell（DMS/Noctalia）和 polkit 代理（KDE/Hyprland）组合 [(架构文档)](docs/architecture.md)
- **WPS Office CN**: 中国版办公套件，中文支持更好 [(架构文档)](docs/architecture.md)
- **中文字体**: Noto CJK、思源、文泉驿等中文字体完整支持 [(架构文档)](docs/architecture.md)
- **中文输入法**: Fcitx5 + RIME 集成 oh-my-rime（薄荷拼音）配置框架，支持拼音、双拼、地球拼音等方案，并附带 Catppuccin 主题 [(架构文档)](docs/architecture.md)
- **默认终端**: foot（轻量级高性能终端），同时支持 kitty、alacritty [(架构文档)](docs/architecture.md)
- **现代化 CLI 工具集**: eza、bat、fd、rg、fzf、yazi（终端文件管理器）、zoxide（智能导航）、fastfetch、btop、dust、duf、tokei、hyperfine、procs 替代传统工具
- **多语言开发支持**: Go、Python、Rust、C/C++ 完整开发环境，包含 LSP 支持 [(架构文档)](docs/architecture.md)
- **模块化音频配置**: 统一的音频模块（rtkit + PipeWire + PulseAudio 兼容性）
- **优化启动配置**: systemd-boot + Plymouth 静默启动，减少启动日志输出
- **Lix 高性能 Nix**: 使用 Lix 替代原生 Nix，性能更优
- **拼写检查支持**: 系统级安装 nuspell 引擎，支持英语拼写检查
- **Nextcloud 客户端**: 云端文件同步支持 [(架构文档)](docs/architecture.md)
- **鼠标侧键支持**: 在 Nemo、Firefox 等应用中使用侧键实现后退/前进功能 [(架构文档)](docs/architecture.md)
- **NixOS 26.05 兼容**: 使用 kdePackages 确保 KDE 包版本兼容性，hardware.graphics（NixOS 24.11+）替代 hardware.opengl
- **中国镜像加速**: 默认配置中科大、清华、北外镜像，加速二进制包下载
- **壁纸仓库**: 提供完整壁纸集合下载地址 `https://github.com/hl4w/wallpaper.git`

## 环境要求

| 项目 | 要求 |
|------|------|
| 系统 | 全新安装推荐使用 NixOS 26.05 安装介质（ISO） |
| Nix | 已启用 flakes（`experimental-features = nix-command flakes`） |
| 权限 | `setup-disk.sh` 需 root；`install.sh` 需能执行 `sudo nixos-generate-config` |
| 磁盘 | 目标磁盘数据会被**完全清空**，请提前备份 |

## 快速开始

### 方式一：全新安装（从 NixOS ISO 启动）

```bash
# 1. 克隆仓库（国内推荐 Gitee，国外使用 GitHub）
git clone https://gitee.com/hl4w/nixfiles.git
# git clone https://github.com/hl4w/nixfiles.git
cd nixfiles

# 2. 一键分区 + 加密 + 部署配置（会清空目标磁盘）
sudo ./scripts/setup-disk.sh -T desktop -W hyprland -S dms /dev/nvme0n1 my-hostname myuser

# 若目标磁盘为 /dev/sda 这类设备，分区名会自动推导（无需手动指定分区号）
# 如需跳过磁盘加密（不推荐）：sudo ./scripts/setup-disk.sh -c -T desktop -W hyprland -S dms /dev/sda my-hostname myuser

# 3. 检查生成的硬件配置后安装系统
sudo nixos-install --flake .#my-hostname

# 4. 重启并进入系统
reboot
```

`setup-disk.sh` 会依次完成：GPT 分区表 → EFI 分区 → LUKS2 加密容器 → LVM（root/swap/home）→ 格式化 → 挂载 → 克隆配置仓库 → 调用 `install.sh` 生成主机配置。非加密模式则跳过 LUKS/LVM，按 60% / 40% 拆分 `/` 与 `/home` 并创建 swapfile。

### 方式二：已有 NixOS 系统，仅初始化主机配置

```bash
git clone https://gitee.com/hl4w/nixfiles.git
cd nixfiles

chmod +x scripts/install.sh
./scripts/install.sh
```

交互模式会依次询问用户名、主机名、主机类型、窗口管理器、桌面 Shell 与 polkit 代理；也可用参数直接指定：

```bash
./scripts/install.sh -y -U myuser -H my-hostname -T desktop -W hyprland -S dms -P kde
```

> `-y` 为非交互模式：缺少必需参数时会直接报错退出，不会阻塞等待输入。

### 方式三：手动部署

```bash
# 1. 克隆仓库
git clone https://gitee.com/hl4w/nixfiles.git
cd nixfiles

# 2. 生成 flake.lock（锁定依赖版本，含 oh-my-rime 输入法框架）
nix flake update

# 3. 创建主机配置目录（复制模板）
cp -r templates/host-template hosts/<hostname>

# 4. 生成硬件配置
#    在安装介质中目标系统根目录挂载于 /mnt 时，需显式指定 --root /mnt
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix

# 5. 编辑 flake.nix，在 nixosConfigurations 中添加主机条目
# my-hostname = mkHost "my-hostname";

# 6. 创建 Home Manager 用户配置
touch home/hosts/<hostname>.nix

# 7. 测试构建（nixosConfigurations 需使用完整属性路径）
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# 8. 部署系统
sudo nixos-rebuild switch --flake .#<hostname>

# 9. 更新用户配置
home-manager switch --flake .#<username>@<hostname>
```

[(详细安装指南)](docs/migration.md)

## 脚本说明

全部脚本均提供中英文两个版本（`*.sh` 为中文，`*_en.sh` 为英文）。

| 脚本 | 用途 | 常用参数 |
|------|------|----------|
| `setup-disk.sh <disk> <host> <user>` | 全新安装：分区、LUKS2+LVM 加密、格式化挂载并部署配置 | `-y` 非交互执行、`-c` 关闭加密、`-r` 指定仓库、`-T/-W/-S` 指定主机类型/窗口管理器/桌面 Shell |
| `install.sh` | 初始化主机配置：生成 `hosts/<host>`、`home/hosts/<host>.nix`、硬件配置，更新占位符 | `-y` 非交互、`-U` 用户名、`-H` 主机名、`-G/-E` Git 用户名/邮箱、`-T/-W/-S/-P` 组件选择、`-N` flake 名称 |
| `update.sh` | 更新 flake 输入并重建系统 | `-H` 指定主机名（默认自动探测） |
| `clean.sh` | 清理 Nix store 与旧系统版本 | `-s` 仅清理 store、`-g` 仅清理旧代、`-a` 全部（默认）、`-y` 自动确认 |
| `setup-direnv.sh` | 配置 direnv 自动加载开发环境 | `-y` 非交互 |
| `wallpaper-color.sh` | 壁纸取色与配色应用 | `-w` 指定壁纸、`-s` 按名称设置、`-d` 随机、`-l` 列表、`-c` 当前配色、`-a` 仅应用配色 |
| `wallpaper-watcher.sh` | 监听壁纸变化并自动更新配色（由 systemd 用户服务调用） | 环境变量 `WATCH_INTERVAL` 控制轮询间隔（秒，默认 5） |

> 脚本均使用 `set -euo pipefail` 与显式参数校验；`setup-disk.sh` 会校验 root 权限与块设备后再执行任何破坏性操作。

## 文档

详细文档请查看 `docs/` 目录：

| 文档 | 说明 |
|------|------|
| `docs/CHANGELOG.md` / `docs/CHANGELOG_EN.md` | 变更日志（中/英） |
| `docs/architecture.md` / `docs/architecture_en.md` | 架构说明、模块结构、配置流程 |
| `docs/shortcuts.md` / `docs/shortcuts_en.md` | 快捷键速查（Hyprland / Niri） |
| `docs/faq.md` / `docs/faq_en.md` | 常见问题与故障排除 |
| `docs/migration.md` / `docs/migration_en.md` | 迁移与安装指南 |

## 项目结构

```
.
├── hosts/                    # 主机配置（系统级，NixOS 原生选项）
│   ├── common/               # 通用系统配置（default / desktop-common / hardware-common）
│   ├── desktop/              # 桌面主机配置
│   ├── laptop/               # 笔记本主机配置
│   └── server/               # 服务器主机配置
├── modules/                  # 系统模块
│   ├── boot/                 # 启动配置（systemd-boot、Plymouth）
│   ├── desktops/             # 桌面环境（hyprland、niri、sddm、shell-dms、shell-noctalia、unified-theme）
│   ├── hardware/             # 硬件配置（nvidia、sound、bluetooth、firmware、mouse）
│   ├── input-method/         # 输入法（Fcitx5 + RIME + oh-my-rime + Catppuccin 主题）
│   ├── services/             # 服务（network、security、virtualisation）
│   └── system/               # 系统基础（fonts 等）
├── home/                     # Home Manager 用户配置（用户级，HM 专属选项）
│   ├── common/               # 通用用户模块（apps、cli、dev-lsp、editor、git、shell、
│   │                         #   input、hyprland、niri、unified-theme、wallpaper-watcher）
│   └── hosts/                # 主机特定用户配置（desktop / laptop / server）
├── scripts/                  # 安装与维护脚本（中英文各一套）
├── templates/                # 模板文件
│   └── host-template/        # 主机配置模板
├── wallpapers/               # 壁纸文件
├── docs/                     # 文档
├── secrets/                  # 敏感配置（不纳入版本控制）
├── .github/                  # CI 工作流
└── flake.nix                 # 入口配置（首次构建前需运行 nix flake update 生成 flake.lock）
```

### 配置层级说明

| 目录 | 级别 | 说明 |
|------|------|------|
| `hosts/` | 系统级 | NixOS 系统配置，由 root 管理，仅使用 NixOS 原生选项 |
| `modules/` | 系统级 | 可复用的 NixOS 模块，可被多个主机导入 |
| `home/` | 用户级 | Home Manager 用户配置，由普通用户管理，仅使用 HM 专属选项 |

> 系统层与用户层严格分离：`gtk.*`、`xdg.*`、`wayland.windowManager.*` 等 Home Manager 选项不得出现在 `modules/` 中；反之 `environment.systemPackages`、`services.*` 等系统选项也不应写入 `home/`。

## 管理命令

### 系统更新

安装完成后，如果修改了任何 Nix 模块，可以直接使用以下命令更新系统：

```bash
# 直接更新系统（推荐）
sudo nixos-rebuild switch --flake .#<hostname>

# 更新 Home Manager 用户配置
home-manager switch --flake .#<username>@<hostname>

# 更新 flake 输入（升级依赖版本）
nix flake update

# 使用脚本一键更新（包含 flake update 和系统重建）
./scripts/update.sh

# 清理旧版本与 Nix store
./scripts/clean.sh

# 检查配置（不执行构建）
nix flake check

# 测试构建（不部署，使用完整属性路径）
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

**说明**:

- 修改 `modules/` 下的系统模块后，运行 `sudo nixos-rebuild switch --flake .#<hostname>` 即可应用更改
- 修改 `home/` 下的用户配置后，运行 `home-manager switch --flake .#<username>@<hostname>` 即可应用更改
- 使用 `nix flake update` 更新所有输入依赖（nixpkgs、home-manager、oh-my-rime 等）
- 建议在部署前使用 `nix flake check` 或完整属性路径的 `nix build` 验证配置正确性
- `nix build .#<hostname>` 仅适用于 flake 暴露了 `packages.<system>.<hostname>` 的场景；本仓库使用 `nixosConfigurations`，请使用上面的完整属性路径

[(脚本使用说明)](docs/architecture.md)

## 常见问题

遇到问题？请查看 [(FAQ)](docs/faq.md)

## 许可证

GNU General Public License v3.0
