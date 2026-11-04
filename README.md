# HL4W（Hack Linux for Workflow） - Nixfiles for NixOS

**Version: v0.0.6**

一套基于 NixOS 26.05 的现代化配置仓库，内置深度优化的 Hyprland & Niri 桌面套件，原生兼容 DMS Shell 与 Noctalia Shell 桌面组件。使用 Nix Flakes + Home Manager 统一管理多台设备的系统与用户环境。

## 特性

### 桌面与外观

- **Hyprland** / **Niri**: Wayland 窗口管理器 [(详细说明)](docs/architecture.md) [(快捷键)](docs/shortcuts.md)
- **桌面 Shell 可选**: 原生兼容 DMS Shell 与 Noctalia Shell，配合 KDE / Hyprland polkit 代理自由组合 [(架构文档)](docs/architecture.md)
- **主题统一**: GTK / Qt / Hyprland / Niri / Shell / SDDM / Fcitx5 统一为 Catppuccin 配色 [(架构文档)](docs/architecture.md)
- **壁纸自动取色**: 使用 pywal 从壁纸提取颜色，监听服务在壁纸变化时自动跟随 [(架构文档)](docs/architecture.md)
- **日夜主题切换**: 根据时间自动切换深浅风格 [(架构文档)](docs/architecture.md)

### 安装与系统

- **一键装机**: `setup-disk.sh` 完成 GPT 分区、LUKS2 + LVM 加密、格式化、挂载与配置部署；`install.sh` 完成主机初始化 [(脚本说明)](#脚本说明)
- **GPU 自动检测**: 安装时自动识别 NVIDIA / AMD / Intel 显卡，智能配置驱动与内核参数 [(架构文档)](docs/architecture.md)
- **模块化架构**: 清晰的目录结构与严格的系统层 / 用户层边界，易于扩展与维护 [(架构文档)](docs/architecture.md)
- **多主机支持**: 桌面、笔记本、服务器统一管理，按主机类型自动装配模块 [(架构文档)](docs/architecture.md)
- **NixOS 26.05 兼容**: 使用 `kdePackages` 保证 KDE 包版本一致，以 `hardware.graphics`（NixOS 24.11+）替代 `hardware.opengl`
- **Lix 高性能 Nix**: 使用 Lix 替代原生 Nix，求值与拉取性能更优
- **优化启动配置**: systemd-boot + Plymouth 静默启动，减少启动日志输出
- **模块化音频配置**: 统一音频模块（rtkit + PipeWire + PulseAudio 兼容层）
- **中国镜像加速**: 默认配置中科大、清华、北外镜像，加速二进制包下载

### 中文与办公

- **中文输入法**: Fcitx5 + RIME 集成 oh-my-rime（薄荷拼音）配置框架，支持拼音、双拼、地球拼音等方案，附带 Catppuccin 主题 [(架构文档)](docs/architecture.md)
- **中文字体**: Noto CJK、思源、文泉驿等字体完整支持 [(架构文档)](docs/architecture.md)
- **拼写检查**: 系统级安装 nuspell 引擎，支持英文拼写检查
- **WPS Office CN**: 中国版办公套件，中文支持更好
- **Nextcloud 客户端**: 云端文件同步支持 [(架构文档)](docs/architecture.md)

### 终端与开发

- **默认终端 foot**: 轻量级高性能终端，同时提供 kitty、alacritty 备选 [(架构文档)](docs/architecture.md)
- **现代化 CLI 工具集**: eza、bat、fd、ripgrep、fzf、yazi（终端文件管理器）、zoxide（智能导航）、fastfetch、btop、dust、duf、tokei、hyperfine、procs 替代传统工具
- **多语言开发支持**: Go、Python、Rust、C/C++ 完整开发环境，含 LSP 支持 [(架构文档)](docs/architecture.md)
- **鼠标侧键支持**: 在 Nemo、Firefox 等应用中用侧键后退 / 前进 [(架构文档)](docs/architecture.md)
- **壁纸仓库**: 完整壁纸集合见 `https://github.com/hl4w/wallpaper.git`

## 环境要求

| 项目 | 要求 |
|------|------|
| 系统 | 全新安装推荐使用 NixOS 26.05 安装介质（ISO） |
| Nix | 已启用 flakes（`experimental-features = nix-command flakes`） |
| 权限 | `setup-disk.sh` 需 root；`install.sh` 需能执行 `sudo nixos-generate-config` |
| 磁盘 | 目标磁盘数据会被**完全清空**，请提前备份 |

## 快速开始

按场景选择一种方式：全新机器用方式一，已有 NixOS 用方式二，需要完全掌控细节用方式三。

### 方式一：全新安装（从 NixOS ISO 启动）

ISO 环境无需预先 clone 仓库，`setup-disk.sh` 会在挂载目标磁盘后自动把配置仓库克隆到 `/mnt/etc/nixos`，再以非交互方式调用 `install.sh` 生成主机配置、`nix flake lock` 锁定依赖、`nixos-generate-config --root /mnt` 生成硬件配置。用户只需检查生成的配置后执行 `nixos-install`。

```bash
# 1. 从 Gitee 或 GitHub 下载 setup-disk.sh
curl -fsSL -o setup-disk.sh https://gitee.com/hl4w/nixfiles/raw/master/scripts/setup-disk.sh
# curl -fsSL -o setup-disk.sh https://raw.githubusercontent.com/hl4w/nixfiles/master/scripts/setup-disk.sh
chmod +x setup-disk.sh

# 2. 一键分区 + 加密 + 部署配置（会清空目标磁盘）
#    <disk>      目标磁盘设备（如 /dev/nvme0n1、/dev/sda），分区名自动推导
#    <hostname>  主机名（同时作为 flake 配置名称）
#    <username>  用户名
sudo ./setup-disk.sh <disk> <hostname> <username>

# 组件未指定时进入交互选择；也可显式指定主机类型 / 窗口管理器 / 桌面 Shell
# sudo ./setup-disk.sh -T desktop -W hyprland -S dms <disk> <hostname> <username>

# 如需跳过磁盘加密（不推荐）：在设备参数前加 -c
# sudo ./setup-disk.sh -c <disk> <hostname> <username>

# 3. 脚本完成后，配置仓库已在 /mnt/etc/nixos；检查硬件配置，然后安装系统
cd /mnt/etc/nixos
# 首次从特定镜像源拉取时，可先执行：nix flake update
sudo nixos-install --flake .#<hostname>

# 4. 重启并进入系统
reboot
```

`setup-disk.sh` 依次完成：GPT 分区表 → EFI 分区 → 数据分区（启用加密时为 LUKS2 容器）→ LVM（swap/root 逻辑卷）→ 格式化 → 挂载 → 克隆配置仓库到 `/mnt/etc/nixos` → 以 `-y` 模式调用 `install.sh` 生成主机配置与硬件配置。无论是否加密都使用 LVM：磁盘只划分 EFI 与数据两个分区，`/` 与 swap 均为逻辑卷，`/home` 位于 `/` 下；swap 大小取磁盘容量的 10%（限制 2–16 GiB）。

`-T`（`desktop`/`laptop`/`server`）、`-W`（`hyprland`/`niri`）、`-S`（`dms`/`noctalia`）用于指定组件；省略时脚本在交互终端中依次提示选择（回车使用默认 `desktop`/`hyprland`/`dms`），`-y` 或 stdin 非终端时直接采用默认值，不会阻塞自动化流程；选择 `server` 会跳过窗口管理器与桌面 Shell 的询问。非法取值会直接报错。

> 已 clone 仓库的场景也可直接在仓库根目录执行 `sudo ./scripts/setup-disk.sh`，行为完全相同——脚本内部始终会克隆到 `/mnt/etc/nixos` 并从那里继续安装流程。

### 方式二：已有 NixOS 系统，仅初始化主机配置

```bash
# 1. 克隆仓库并 cd 进去
git clone https://gitee.com/hl4w/nixfiles.git
# git clone https://github.com/hl4w/nixfiles.git
cd nixfiles

# 2. 首次运行，生成 flake.lock 锁定依赖版本（含 oh-my-rime 输入法框架）
nix flake update

# 3. 运行 install.sh 生成主机配置（交互模式下依次询问各组件）
chmod +x scripts/install.sh
./scripts/install.sh

# 也可一次性传入所有参数
# ./scripts/install.sh -y -U myuser -H my-hostname -T desktop -W hyprland -S dms -P kde

# 4. install.sh 完成后，确认硬件配置已生成
ls hosts/<hostname>/hardware-configuration.nix || sudo nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix

# 5. 部署系统配置（首次构建较慢）
sudo nixos-rebuild switch --flake .#<hostname>

# 6. 部署用户配置（可选，首次可能需要等上一步完成）
home-manager switch --flake .#<username>@<hostname>
```

install.sh 会替换 `flake.nix` 中的 `USERNAME = "youruser"` 占位符、在 `nixosConfigurations` 中插入新主机、更新 `home/common/git.nix` 中的 Git 用户名与邮箱、`nix flake lock` 生成锁文件、`nixos-generate-config --root /`（已有系统）生成硬件配置，最后 `nix flake check` 验证语法。

### 方式三：手动部署

```bash
# 1. 克隆仓库
git clone https://gitee.com/hl4w/nixfiles.git
cd nixfiles

# 2. 生成 flake.lock（锁定依赖版本，含 oh-my-rime 输入法框架）
nix flake update

# 3. 复制主机模板
cp -r templates/host-template hosts/<hostname>

# 4. 生成硬件配置（安装介质中目标系统根目录挂载于 /mnt 时需加 --root /mnt）
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix

# 5. 在 flake.nix 的 nixosConfigurations 中添加主机条目
#    my-hostname = mkHost "my-hostname";

# 6. 创建 Home Manager 用户配置
touch home/hosts/<hostname>.nix

# 7. 测试构建、部署系统、更新用户配置
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
sudo nixos-rebuild switch --flake .#<hostname>
home-manager switch --flake .#<username>@<hostname>
```

[(详细安装指南)](docs/migration.md)

### 部署前验证

```bash
# 求值检查（不编译）
nix flake check

# 测试构建（不部署）
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

> 本仓库通过 `nixosConfigurations` 暴露主机，务必使用完整属性路径；`nix build .#<hostname>` 仅在 flake 额外暴露 `packages.<system>.<hostname>` 时可用。

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
│   └── system/               # 系统基础（fonts、Lix 等）
├── home/                     # Home Manager 用户配置（用户级，Home Manager 专属选项）
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

### 配置层级

| 目录 | 级别 | 说明 |
|------|------|------|
| `hosts/` | 系统级 | NixOS 系统配置，由 root 管理，仅使用 NixOS 原生选项 |
| `modules/` | 系统级 | 可复用的 NixOS 模块，可被多个主机导入 |
| `home/` | 用户级 | Home Manager 用户配置，由普通用户管理，仅使用 Home Manager 专属选项 |

> 系统层与用户层严格分离：`gtk.*`、`xdg.*`、`wayland.windowManager.*` 等 Home Manager 选项不得出现在 `modules/` 中；反之 `environment.systemPackages`、`services.*` 等系统选项也不应写入 `home/`。

## 脚本说明

全部脚本均提供中英文两个版本（`*.sh` 为中文，`*_en.sh` 为英文）。

| 脚本 | 用途 | 常用参数 |
|------|------|----------|
| `setup-disk.sh <disk> <host> <user>` | 全新安装：分区、LUKS2 + LVM 加密、格式化挂载并部署配置 | `-y` 非交互执行、`-c` 关闭加密、`-r` 指定仓库、`-T/-W/-S` 指定主机类型 / 窗口管理器 / 桌面 Shell（省略时交互选择） |
| `install.sh` | 初始化主机配置：生成 `hosts/<host>`、`home/hosts/<host>.nix` 与硬件配置，更新占位符 | `-y` 非交互、`-U` 用户名、`-H` 主机名、`-G/-E` Git 用户名 / 邮箱、`-T/-W/-S/-P` 组件选择、`-N` flake 配置名称 |
| `update.sh` | 更新 flake 输入并重建系统 | `-H` 指定主机名（默认自动探测） |
| `clean.sh` | 清理 Nix store 与旧系统代 | `-s` 仅清理 store、`-g` 仅清理旧系统代、`-a` 全部（默认）、`-y` 自动确认 |
| `setup-direnv.sh` | 配置 direnv 自动加载开发环境 | `-y` 非交互 |
| `wallpaper-color.sh` | 壁纸取色与配色应用 | `-w` 指定壁纸、`-s` 按名称设置、`-d` 随机、`-l` 列表、`-c` 当前配色、`-a` 仅应用配色 |
| `wallpaper-watcher.sh` | 监听壁纸变化并自动更新配色（由 systemd 用户服务调用） | 环境变量 `WATCH_INTERVAL` 控制轮询间隔（秒，默认 5） |

> 全部脚本使用 `set -euo pipefail` 与显式参数校验；`setup-disk.sh` 在执行任何破坏性操作前会校验 root 权限与块设备是否存在。

## 日常管理

```bash
# 应用系统模块（modules/）改动
sudo nixos-rebuild switch --flake .#<hostname>

# 应用用户配置（home/）改动
home-manager switch --flake .#<username>@<hostname>

# 更新全部 flake 输入（nixpkgs、home-manager、oh-my-rime 等）
nix flake update

# 一键更新（flake update + 系统重建）
./scripts/update.sh

# 清理旧系统代与 Nix store
./scripts/clean.sh

# 求值检查与测试构建
nix flake check
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

## 文档

详细文档位于 `docs/` 目录：

| 文档 | 说明 |
|------|------|
| `docs/architecture.md` / `docs/architecture_en.md` | 架构说明、模块结构、配置流程与持续集成 |
| `docs/migration.md` / `docs/migration_en.md` | 迁移与安装指南 |
| `docs/faq.md` / `docs/faq_en.md` | 常见问题与故障排除 |
| `docs/shortcuts.md` / `docs/shortcuts_en.md` | 快捷键速查（Hyprland / Niri） |
| `docs/glossary.md` / `docs/glossary_en.md` | 术语对照表与书写规范 |
| `docs/CHANGELOG.md` / `docs/CHANGELOG_EN.md` | 变更日志 |

## 常见问题

遇到问题请先查阅 [(FAQ)](docs/faq.md)。

## 许可证

GNU General Public License v3.0
