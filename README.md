# HL4W（Hack Linux for Workflow） - Nixfiles for NixOS

**Version: v0.0.5**

一套基于 NixOS 26.05 的现代化配置仓库，内置深度优化的 Hyprland & Niri 桌面套件，原生兼容 Noctalia & DMS Shell 桌面组件。使用 Nix Flakes + Home Manager 统一管理多台设备的系统与用户环境。

## 特性

- **Hyprland** / **Niri**: Wayland 窗口管理器 [(详细说明)](docs/architecture.md)
- **模块化架构**: 清晰的目录结构，易于扩展和维护 [(架构文档)](docs/architecture.md)
- **多主机支持**: 桌面、笔记本、服务器统一管理 [(架构文档)](docs/architecture.md)
- **GPU 自动检测**: 安装时自动识别 NVIDIA/AMD/Intel 显卡，智能配置驱动和内核参数 [(架构文档)](docs/architecture.md)
- **主题统一**: GTK/Qt/Hyprland/Niri/Shell/SDDM 统一配色 [(架构文档)](docs/architecture.md)
- **壁纸自动取色**: 使用 pywal 从壁纸提取颜色 [(架构文档)](docs/architecture.md)
- **日夜主题切换**: 自动根据时间切换深浅风格 [(架构文档)](docs/architecture.md)
- **WPS Office CN**: 中国版办公套件，中文支持更好 [(架构文档)](docs/architecture.md)
- **中文字体**: Noto CJK、思源、文泉驿等中文字体完整支持 [(架构文档)](docs/architecture.md)
- **默认终端**: foot（轻量级高性能终端），同时支持 kitty、alacritty [(架构文档)](docs/architecture.md)
- **Nextcloud 客户端**: 云端文件同步支持 [(架构文档)](docs/architecture.md)
- **鼠标侧键支持**: 在 Nemo、Firefox 等应用中使用侧键实现后退/前进功能 [(架构文档)](docs/architecture.md)
- **灵活桌面配置**: 支持动态选择窗口管理器（Hyprland/Niri）、桌面 Shell（DMS/Noctalia）和 polkit 代理（KDE/Hyprland）组合 [(架构文档)](docs/architecture.md)
- **多语言开发支持**: Go、Python、Rust、C/C++ 完整开发环境，包含 LSP 支持 [(架构文档)](docs/architecture.md)
- **NixOS 26.05 兼容**: 使用 kdePackages 确保 KDE 包版本兼容性，hardware.graphics (NixOS 24.11+) 替代 hardware.opengl
- **现代化 CLI 工具集**: eza、bat、fd、rg、fzf、yazi（终端文件管理器）、zoxide（智能导航）、fastfetch、btop、dust、duf、tokei、hyperfine、procs 替代传统工具
- **优化启动配置**: systemd-boot + Plymouth 静默启动，减少启动日志输出
- **Lix 高性能 Nix**: 使用 Lix 替代原生 Nix，性能更优
- **模块化音频配置**: 统一的音频模块（rtkit + PipeWire + PulseAudio 兼容性）
- **拼写检查支持**: 系统级安装 nuspell 引擎，支持英语拼写检查
- **中国镜像加速**: 默认配置中科大、清华、北外镜像，加速二进制包下载
- **壁纸仓库**: 提供完整壁纸集合下载地址 `https://github.com/hl4w/wallpaper.git`

## 快速开始

### 使用安装脚本（推荐）

```bash
# 克隆仓库
git clone <repo-url>
cd nixfiles26

# 运行安装脚本
chmod +x scripts/install.sh
./scripts/install.sh
```

### 手动部署

```bash
# 1. 克隆仓库
git clone <repo-url>
cd nixfiles26

# 2. 创建主机配置目录（复制模板）
cp -r templates/host-template hosts/<hostname>

# 3. 生成硬件配置
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix

# 4. 编辑 flake.nix，在 nixosConfigurations 中添加主机条目
# my-hostname = mkHost "my-hostname";

# 5. 创建 Home Manager 用户配置
touch home/hosts/<hostname>.nix

# 6. 构建配置
nix build .#<hostname>

# 7. 部署系统
sudo nixos-rebuild switch --flake .#<hostname>

# 8. 更新用户配置
home-manager switch --flake .#<username>@<hostname>
```

[(详细安装指南)](docs/migration.md)

## 文档

详细文档请查看 `docs/` 目录：

| 文档 | 说明 |
|------|------|
| `docs/changelog.md` | 变更日志 |
| `docs/changelog_en.md` | 变更日志（英文） |
| `docs/architecture.md` | 架构说明、模块结构、配置流程 |
| `docs/architecture_en.md` | 架构说明（英文） |
| `docs/faq.md` | 常见问题与故障排除 |
| `docs/faq_en.md` | 常见问题与故障排除（英文） |
| `docs/migration.md` | 迁移指南 |
| `docs/migration_en.md` | 迁移指南（英文） |

## 项目结构

```
.
├── hosts/                    # 主机配置（系统级）
│   ├── common/               # 通用主机配置
│   ├── desktop/              # 桌面主机配置（configuration.nix）
│   ├── laptop/               # 笔记本主机配置（configuration.nix）
│   └── server/               # 服务器主机配置（configuration.nix）
├── modules/                  # 系统模块
│   ├── boot/                 # 启动相关配置
│   ├── desktops/             # 桌面环境配置（Hyprland、Niri、主题）
│   ├── hardware/             # 硬件相关配置
│   ├── input-method/         # 输入法配置（Fcitx5 + RIME）
│   ├── services/             # 服务配置（网络、安全、虚拟化）
│   └── system/               # 系统基础配置（字体、用户、环境变量）
├── home/                     # Home Manager 用户配置（用户级）
│   ├── common/               # 通用用户配置（应用、Shell、终端）
│   └── hosts/                # 主机特定用户配置
│       ├── desktop/          # 桌面特定软件包
│       ├── laptop/           # 笔记本特定软件包
│       └── server/           # 服务器特定配置
├── scripts/                  # 辅助脚本
├── templates/                # 模板文件
│   └── host-template/        # 主机配置模板
├── wallpapers/               # 壁纸文件
├── docs/                     # 文档
├── secrets/                  # 敏感配置（不纳入版本控制）
├── flake.nix                 # 入口配置
└── flake.lock                # 版本锁定
```

### 配置层级说明

| 目录 | 级别 | 说明 |
|------|------|------|
| `/hosts/` | 系统级 | NixOS 系统配置，由 root 管理 |
| `/home/` | 用户级 | Home Manager 用户配置，由普通用户管理 |

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

# 清理旧版本
./scripts/clean.sh

# 检查配置（不执行构建）
nix flake check

# 测试构建（不部署）
nix build .#<hostname>
```

**说明**:
- 修改 `modules/` 目录下的系统模块后，运行 `sudo nixos-rebuild switch --flake .#<hostname>` 即可应用更改
- 修改 `home/` 目录下的用户配置后，运行 `home-manager switch --flake .#<username>@<hostname>` 即可应用更改
- 使用 `nix flake update` 更新所有输入依赖（nixpkgs、home-manager 等）
- 建议在部署前使用 `nix flake check` 或 `nix build .#<hostname>` 验证配置正确性

[(脚本使用说明)](docs/architecture.md)

## 常见问题

遇到问题？请查看 [(FAQ)](docs/faq.md)

## 许可证

GNU General Public License v3.0