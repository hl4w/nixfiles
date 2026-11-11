# 术语对照表

本文档定义 HL4W 项目文档中的规范术语。所有中文文档（README、`docs/*.md`）应遵循本表；英文文档对应使用「英文规范术语」列。

> 变更日志（`docs/CHANGELOG.md`、`docs/CHANGELOG_EN.md`）记录历史事实，保留当时表述，不做术语回改。

## 产品与版本

| 规范术语（中） | 英文规范术语 | 代码 / 标识符 | 说明 | 避免写法 |
|---------------|-------------|--------------|------|----------|
| HL4W（Hack Linux for Workflow） | HL4W (Hack Linux for Workflow) | — | 项目名称，首次出现给出全称 | `Hack Linux`、`hl4w 项目` |
| 配置仓库 | configuration repository | — | 本仓库定位 | 配置库、dotfiles 仓库 |
| NixOS 26.05 | NixOS 26.05 | `nixos-26.05` | 目标系统版本，首次出现写全称 | `26.05 系统`、`NixOS 26` |
| Nix Flakes | Nix Flakes | `flake.nix`、`flake.lock` | 依赖锁定与配置入口 | `Flakes`、`flake 文件`（指代入口时） |
| flake 输入 | flake input | `inputs.*` | flake 的依赖项（如 nixpkgs、oh-my-rime） | flake 依赖项、inputs |
| flake 配置名称 | flake configuration name | `-N/--name`、`nixosConfigurations.<name>` | 安装脚本中的配置名，默认取主机名 | Flake 名称、flake 名称 |

## 配置层级

| 规范术语（中） | 英文规范术语 | 代码 / 标识符 | 说明 | 避免写法 |
|---------------|-------------|--------------|------|----------|
| 系统级 | system-level | `hosts/`、`modules/`、`nixosConfigurations` | 由 root 管理的 NixOS 配置 | 系统层配置（混用）、root 配置 |
| 用户级 | user-level | `home/`、`homeConfigurations` | 由普通用户管理的 Home Manager 配置 | 用户层配置（混用）、普通配置 |
| Home Manager | Home Manager | `home-manager`（命令） | 用户环境管理工具；中文正文不再使用「HM」缩写 | HM、home manager（首字母小写） |
| 主机 | host | `hosts/<hostname>` | 一台被管理的设备 | 宿主机、节点、机器 |
| 主机类型 | host type | `desktop`、`laptop`、`server` | 主机分类，决定装配的模块 | 设备类型、机器类型 |

## 桌面组件

| 规范术语（中） | 英文规范术语 | 代码 / 标识符 | 说明 | 避免写法 |
|---------------|-------------|--------------|------|----------|
| 窗口管理器 | window manager | `programs.hyprland`、`programs.niri` | Hyprland / Niri | WM、窗口管理 |
| Lua 配置 | Lua config | `configType = "lua"`、`~/.config/hypr/hyprland.lua` | Hyprland 0.55+ 官方配置格式，存在即忽略 `hyprland.conf` | lua 配置文件、Lua 脚本（指配置时） |
| 调度器 | dispatcher | `hl.dsp.*`（如 `hl.dsp.window.close()`） | Hyprland Lua 中执行动作的函数对象 | 命令、动作命令 |
| 工作区 | workspace | `hl.dsp.focus({ workspace = N })` | Hyprland / Niri 的虚拟桌面单元 | 桌面（指虚拟桌面时）、虚拟屏 |
| 桌面 Shell | desktop shell | 选项值 `dms`、`noctalia` | 桌面面板/壳层组件类别 | Desktop Shell、Shell 组件 |
| DMS Shell | DMS Shell | `dms-shell`（包/命令）、`programs.dms-shell`（模块）、`shell-dms.nix` | DankMaterialShell，轻量级桌面 Shell | DMS-Shell、DMS、dms shell |
| Noctalia Shell | Noctalia Shell | `noctalia-shell`（包，v4）、`shell-noctalia.nix` | Noctalia 桌面 Shell（当前采用 v4） | Noctalia-Shell、Noctalia、noctalia shell |
| polkit 代理 | polkit agent | `-P/--polkit-agent`、`kde`、`hyprland` | 权限提权代理 | polkit 代理程序、polkit-agent |
| 输入法 | input method | `fcitx5`、`rime`、`oh-my-rime` | Fcitx5 + RIME 组合 | 输入法框架（泛指整体时）、IME |
| 配色 / 主题 | color scheme / theme | `catppuccin` | 「主题」指整体风格，「配色」指颜色方案 | 皮肤、颜色主题（混用） |

## 运维与安装

| 规范术语（中） | 英文规范术语 | 代码 / 标识符 | 说明 | 避免写法 |
|---------------|-------------|--------------|------|----------|
| 安装脚本 | installation script | `scripts/install.sh` | 生成主机与用户配置 | 部署脚本（指本脚本时） |
| 磁盘安装脚本 | disk setup script | `scripts/setup-disk.sh` | 分区、加密、格式化、挂载 | 装机脚本、格式化脚本 |
| 安装介质 | installer image | NixOS ISO | 用于全新安装的 NixOS 镜像 | 安装盘、安装 U 盘 |
| 壁纸取色 | wallpaper color extraction | `wal`（pywal） | 从壁纸提取颜色 | 抽色、抓取壁纸颜色 |
| 应用配色 | apply color scheme | `wal -R`、`wallpaper-color.sh` | 将已有配色写入各应用 | 更新配色（混用） |
| 系统代 | generation | `nixos-rebuild` 代、`home-manager` 代 | 系统/用户配置的一代快照 | 旧版本、版本号（指代 generation 时） |
| 旧系统代 | old generation | `clean.sh -g` | 非当前代的系统快照 | 旧代、历史版本 |
| 占位符 | placeholder | `youruser`、`Your Name` | 待替换的模板值 | 变量、占位字段 |
| 磁盘加密 | disk encryption | LUKS2、`cryptsetup` | 本项目使用 LUKS2 容器 | 硬盘加密（混用）、加密盘 |
| 逻辑卷 | logical volume (LV) | `lvcreate`、`root`/`swap` | LVM 逻辑卷（本项目磁盘只划分 EFI 与数据两个分区，数据分区创建 LVM VG 后划分 root/swap 两个 LV，`/home` 位于 `/` 下） | 分区（指 LV 时） |

## 书写规范

- 代码、命令、路径、选项名一律使用反引号，如 `scripts/install.sh`、`programs.dms-shell`、`home.stateVersion`。
- 中文文档使用全角标点；英文文档使用半角标点并保留一个空格分隔句子。
- 组合表述统一顺序：**DMS Shell / Noctalia Shell**、**Hyprland / Niri**、**GTK / Qt**。
- 版本号统一写作 `v0.0.6`（小写 v）。
- 同义词只保留一个：指代本仓库提供的组件组合时使用「桌面套件」（desktop suite）；描述系统的桌面会话/环境本身时仍用「桌面环境」。
