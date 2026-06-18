# HL4W NixOS Configuration Changelog

所有重要的项目变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

## [v0.0.5] - 2026-06-16
### Added
- **GPL v3.0 许可证更新**: 验证并确认项目使用完整的 GNU General Public License v3.0
- **文档版本统一**: 更新所有文档文件版本号为 v0.0.5
  - `flake.nix` - Flake 入口文件版本更新
  - `docs/architecture.md` - 架构文档版本更新
  - `docs/architecture_en.md` - 架构文档（英文）版本更新
- **作者信息**: 在 README 文档和所有脚本文件中添加作者信息 "Author: Silas Zhang (2026)"
- **Bash Shell 支持**: 添加完整的 Bash 配置支持
  - 系统级安装和启用 Bash (`modules/system/default.nix`)
  - 用户级 Bash 配置 (`home/common/shell.nix`)
  - Starship 提示符集成 Bash
  - Bash 和 Zsh 共享相同的环境变量和别名配置
- **仓库名称更新**: 将仓库名称从 `nixfiles26` 改为 `nixfiles`
- **仓库 URL 更新**: 添加 Gitee 和 GitHub 双仓库地址
  - 国内用户: `https://gitee.com/hl4w/nixfiles.git`
  - 国外用户: `https://github.com/hl4w/nixfiles.git`
- **快捷键文档**: 创建 Hyprland/Niri 快捷键参考文档
  - `docs/shortcuts.md` - 中文快捷键文档
  - `docs/shortcuts_en.md` - 英文快捷键文档
- **Firefox 快捷键**: 添加 `Super+B` 打开 Firefox 浏览器
- **统一应用程序快捷键**: 统一 Hyprland 和 Niri 的应用程序快捷键配置
  - `Super+R` - 应用启动器 (Rofi)
  - `Super+Return` - 终端 (Foot)
  - `Super+E` - 文件管理器 (Nemo)
  - `Super+B` - Firefox 浏览器
  - `Super+Q` - 关闭窗口
  - `Super+C` - VSCodium
  - `Super+P` - 电源菜单 (Rofi)
  - `Super+Shift+Q` - 退出窗口管理器
- **VSCodium 支持**: 添加 VSCodium（开源版 VS Code）作为默认编辑器
  - 用户级安装 `vscodium` 包 (`home/common/apps.nix`)
  - 快捷键 `Super+C` 打开 VSCodium
- **脚本 Shebang 更新**: 将所有 sh 脚本的 shebang 从 `#!/bin/sh` 更新为 `#!/usr/bin/env bash`，确保 bash 语法正确执行
### Changed
- **许可证验证**: 确认 LICENSE 文件内容符合 GNU GPL v3.0 标准文本

## [v0.0.4] - 2026-06-15

### Added

- **脚本标准化**: 统一所有 shell 脚本的结构和风格
  - 添加一致的颜色变量 (RED, GREEN, YELLOW, NC)
  - 标准化日志函数 (`info()`, `warn()`, `error()`)
  - 添加 `confirm()` 函数支持非交互式模式
  - 添加 `usage()` 函数显示帮助信息
  - 为所有脚本添加 HL4W 品牌标识
- **update.sh 增强**: 添加主机名参数支持，可指定目标主机进行构建
- **setup-direnv.sh 增强**: 添加自动 Shell 类型检测，支持 bash/zsh/fish
- **脚本中英文同步**: 确保所有中英文脚本版本功能完全一致

### Changed

- **install.sh/install_en.sh 同步**: 更新英文版本以匹配中文版本的所有改进（主机备份、flake 验证、更新命令说明）
- **clean.sh/clean_en.sh 优化**: 更新 confirm 函数支持非交互式模式

## [v0.0.3] - 2026-06-15

### Added

- **完善 CLI 工具集**: 新增更多现代化命令行工具
  - `yazi` - 快速终端文件管理器（用 Rust 编写）
  - `dust` - 磁盘使用分析工具
  - `duf` - 磁盘空间查看工具
  - `tokei` - 代码统计工具
  - `hyperfine` - 命令性能测试工具
  - `procs` - 增强版 ps 命令
  - `zoxide` - 智能目录导航工具
- **Yazi 配置集成**: 在 `home/common/cli.nix` 中配置 Yazi 文件管理器，支持 zoxide 集成
- **Zoxide 导航**: 在 `home/common/cli.nix` 中启用 Zoxide 智能目录跳转
- **壁纸仓库说明**: 在 `wallpapers/README.md` 中添加完整壁纸集合的下载地址 `https://github.com/hl4w/wallpaper.git`
- **项目版本统一更新**: 更新所有文档文件中的版本号为 v0.0.3

### Changed

- **CLI 工具模块化**: 将 CLI 工具从 `apps.nix` 分离到独立的 `home/common/cli.nix` 模块，结构更清晰
- **shell.nix 精简**: 移除与 CLI 模块重复的配置，保持职责分离
- **文档内容更新**: 更新 README、架构文档、FAQ、迁移指南，反映最新的项目状态
- **壁纸 README 更新**: 更新 `wallpapers/README.md` 中的文件列表，仅保留实际存在的 `default.jpg`

### Fixed

- **修复 Lix 配置**: 修正 `modules/system/default.nix` 中 Lix 的引用方式，使用 `pkgs.lix` 替代 `pkgs.lixPackageSets.stable.lix`
- **修复目录结构文档**: 更新架构文档中的目录树，确保与实际文件结构一致
- **修复壁纸 README**: 修正默认壁纸文件名从 `default.png` 为 `default.jpg`

## [v0.0.2] - 2026-06-14

### Added

- **GPU 自动检测**：在 install.sh 中添加 lspci 硬件检测功能
  - 支持 NVIDIA 显卡：自动添加 `modules/hardware/nvidia.nix` 导入和内核参数
  - 支持 AMD/ATI 显卡：自动添加 `amdgpu.si_support=1` 和 `amdgpu.cik_support=1` 内核参数
  - 支持 Intel 集成显卡：自动添加 `i915.enable_psr=0` 内核参数
  - 未知显卡使用通用配置
- **英文版本支持**：为所有脚本创建英文版本
  - `scripts/install_en.sh` - 安装脚本英文版本
  - `scripts/wallpaper-watcher_en.sh` - 壁纸监听器英文版本
  - `scripts/wallpaper-color_en.sh` - 壁纸配色脚本英文版本
  - `scripts/setup-disk_en.sh` - 磁盘设置脚本英文版本
  - `scripts/clean_en.sh` - 清理脚本英文版本
  - `scripts/update_en.sh` - 更新脚本英文版本
  - `scripts/setup-direnv_en.sh` - direnv 设置脚本英文版本
- **英文文档**：创建英文版本的项目文档
  - `README_en.md` - 项目说明文档（英文）
  - `docs/CHANGELOG_EN.md` - 变更日志（英文）
  - `docs/architecture_en.md` - 架构说明（英文）
  - `docs/faq_en.md` - 常见问题（英文）
  - `docs/migration_en.md` - 迁移指南（英文）
- **开发语言 LSP 支持**：为 Go、Python、Rust、C/C++ 添加完整的语言支持（用户级配置）
  - **C/C++**: clangd、clang-tools、cmake、ninja、gdb、lldb
  - **Go**: go、gopls
  - **Python**: python3、pyright
  - **Rust**: rustc、rust-analyzer、rustfmt、cargo
- **Neovim LSP 配置**：为所有支持的语言配置了 LSP 服务器（nil_ls、clangd、gopls、pyright、rust_analyzer）

### Changed

- **NixOS 24.11+ 显卡配置更新**：将 `hardware.opengl` 替换为 `hardware.graphics`
  - `hardware-common.nix` 使用 `hardware.graphics.enable = true`
  - install.sh 安装时自动生成 GPU 通用配置
  - 简化 OpenGL 配置（`driSupport` 等选项已自动启用）
- **音频配置模块化**：将音频配置统一到 `modules/hardware/sound.nix`
  - 包含 rtkit（实时音频服务）、PipeWire（现代音频服务器）、PulseAudio 兼容性
  - `hardware-common.nix` 简化，仅保留注释引用
- **桌面配置优化**：重构 `desktop-common.nix`，分离默认值与主机特定配置
  - `modules/desktops/desktop.nix` 提供桌面选项默认值
  - `hosts/common/desktop-common.nix` 仅包含通用配置（用户组等）
  - install.sh 根据用户选择生成主机级别配置
- **文档结构优化**：将 changelog 移动到 `docs/` 目录
  - `CHANGELOG.md` → `docs/CHANGELOG.md`
  - `CHANGELOG_EN.md` → `docs/CHANGELOG_EN.md`
- **统一文档命名规范**：将英文文档命名从 `.en.md` 改为 `_en.md`
  - `README.en.md` → `README_en.md`
  - `docs/architecture.en.md` → `docs/architecture_en.md`
  - `docs/faq.en.md` → `docs/faq_en.md`
  - `docs/migration.en.md` → `docs/migration_en.md`
- **更新 README**：修复文档链接引用，从 `.zh.md` 改为 `.md`
- **更新架构文档**：完善目录结构树，添加所有实际文件：
  - `modules/boot/plymouth.nix` - Plymouth 启动动画配置
  - `modules/hardware/firmware.nix` - 额外固件支持
  - `modules/hardware/nvidia.nix` - NVIDIA 显卡驱动配置
  - `modules/hardware/sound.nix` - 音频系统配置
  - `home/common/wallpaper-watcher.nix` - 壁纸监听器用户服务
  - `secrets/example.age` 和 `secrets/README.md`
  - `wallpapers/` 目录下所有壁纸文件
- **更新项目版本号**：`flake.nix`、`README.md`、`README_en.md` 均更新为 v0.0.2
- **NixOS 26.05 兼容性优化**：更新 `breeze-icons` 包引用方式，从 `pkgs.breeze-icons` 改为 `pkgs.kdePackages.breeze-icons`，确保 KDE 包版本兼容性
- **现代化系统工具**：移除 `htop`，添加 `btop`（更现代化的系统监控）和 `fastfetch`（快速系统信息展示）到用户级配置
- **扩展字体支持**：添加 `noto-fonts-color-emoji`、`fira-code`、`source-code-pro`、`iosevka`、`font-awesome` 字体包
- **添加拼写检查器**：系统级安装 `nuspell` 引擎（比 Hunspell 快 3 倍）和英语词典（`hunspellDicts.en-us`、`hunspellDicts.en-gb-ise`）。注意：Nuspell/Hunspell 不支持中文拼写检查
- **优化 boot 配置**：
  - 移除显式的 `boot.initrd.systemd.enable`（NixOS 26.05 默认启用）
  - 添加静默启动内核参数：`quiet`、`splash`、`rd.udev.log_level=3`、`rd.systemd.show_status=auto`
  - 设置 `boot.consoleLogLevel = 3` 和 `boot.initrd.verbose = false` 减少启动日志
  - 合并 `loader.efi` 和 `loader.systemd-boot` 配置
  - 显式禁用其他引导加载器（grub、generic-extlinux-compatible）
- **使用 Lix 高性能 Nix**：将 `nix.package` 从默认的 Nix 替换为 `pkgs.lixPackageSets.stable.lix`，使用 overlay 确保依赖 Nix 的工具也使用 Lix，提升 eval 和 fetch 性能
- **Niri 使用官方库**：从 flake 输入移除 `niri`，改用 NixOS 26.05 官方库中的 `pkgs.niri`
  - 移除 `flake.nix` 中的 `niri.url = "github:YaLTeR/niri/main"`
  - 更新 `modules/desktops/niri.nix` 使用 `pkgs.niri` 而不是 `inputs.niri.packages.x86_64-linux.niri`

## [v0.0.1] - 2026-06-11

### Added

- **统一主题配置模块** (`unified-theme.nix`)
  - GTK、Qt、Hyprland、Niri、Noctalia-Shell、DMS-Shell、SDDM 共享相同的配色和图标风格
  - 主题：Adwaita-dark（深色模式）/ Adwaita（浅色模式）
  - 图标：Papirus-Dark / Papirus
  - 字体：Noto Sans CJK SC 11pt（支持中文）
  - 窗口边框：活动窗口绿色（rgba(34, 197, 94)），非活动窗口灰色（rgba(71, 85, 105)）
- **壁纸自动取色配色系统**（pywal）
  - 支持从壁纸提取颜色自动应用到终端、Shell、编辑器
  - 创建 `scripts/wallpaper-color.sh` 脚本
  - 命令别名：`wp-color`、`wp-random`、`wp-apply`、`wp-list`
- **日夜主题自动切换功能**
  - 支持根据时间自动切换深浅主题风格（6:00-18:00为白天）
  - 提供命令行工具：`theme-auto`、`theme-dark`、`theme-light`
  - 可配置日夜切换时间
- **终端模拟器**：添加 kitty 和 foot 终端（与 alacritty 并列）
- **用户级 C/C++ 语言支持**：clangd、clang-tools、cmake、ninja、gdb、lldb
- **优化 `host-template/configuration.nix`**：添加可选模块注释，使其更有效
- **Nextcloud 客户端**：在用户级添加 `nextcloud-client` 包，支持云端文件同步
- **整合 Nemo 相关包到用户级**：nemo、nemo-extensions、evince、eog 统一在 `home/common/apps.nix` 中管理
- **默认终端改为 foot**：将 Hyprland 和 Niri 的默认终端从 kitty 改为 foot（轻量级高性能终端）
- **桌面环境标识动态切换**：`unified-theme.nix` 支持根据窗口管理器自动设置 `XDG_CURRENT_DESKTOP` 环境变量
- **重构主机特定软件包配置**：将桌面/笔记本特定软件包从 `install.sh` 迁移到独立的用户级配置文件
- **分离系统级和用户级配置**：`/hosts/` 目录仅包含系统级配置，`/home/hosts/` 目录包含用户级配置，职责清晰
- **桌面配置模块** (`modules/desktops/desktop.nix`)：支持动态选择窗口管理器（hyprland/niri）、桌面 shell（dms/noctalia）和 polkit 代理（kde/hyprland），无需修改 imports
- **鼠标侧键支持**：在 Hyprland 中添加 `pass` 绑定（Button 8/9），让应用程序（如 Nemo、Firefox）能够正确处理后退/前进功能
- **更新 Qt 相关包名**：适配 NixOS 26.05 包库（`adwaita-qt` → `qt6Packages.adwaita-qt`，`qt6-multimedia` → `qt6Packages.qtmultimedia`，`fcitx5-qt` → `qt6Packages.fcitx5-qt`，`qtwayland` → `qt6Packages.qtwayland`）

### Changed

- 将 `display-manager.nix` 重命名为 `sddm.nix`，便于未来扩展其他显示管理器（如 LightDM、GDM）
- 移除 fcitx5 的 X11 支持，仅保留 Wayland 支持
- 将 `input-method.nix` 从 `hardware/` 目录移动到 `modules/` 根目录
- 移除 podman，只保留 docker（桌面端使用）
- 将 Thunar 替换为 Nemo（支持 PDF/图片预览）
- 将 Wofi 替换为 Rofi（更好的 Wayland 支持）
- 将 Exa 替换为 Eza（exa 已弃用）
- 将 LibreOffice 替换为 WPS Office CN（中国版，中文支持更好）
- **优化字体配置**
  - 创建独立的 `modules/system/fonts.nix` 模块，分离字体配置与主题配置
  - 默认字体使用英文（Noto Sans），通过 FontConfig fallback 支持中文
  - 添加 WPS Office CN 字体别名映射（宋体、黑体、微软雅黑等）
  - 安装完整中文字体：Noto CJK、思源系列、文泉驿系列
- 移除 Waybar，使用窗口管理器自带状态栏
- **优化模块结构，移除重复的包安装**
  - 合并 `unified-theme.nix` 中重复的 `environment.systemPackages` 块
  - 清理 `hyprland.nix`、`niri.nix` 中与用户级重复的包
  - 删除冗余的 `wallpaper-color.nix` 文件（内容已合并）
- **重构项目结构，按功能分类组织模块**
  - 创建 `modules/system/` 目录，存放系统基础配置
  - 创建 `modules/services/` 目录，存放网络、安全、虚拟化服务配置
  - 创建 `modules/input-method/` 目录，存放输入法配置
  - 使用 `default.nix` 作为模块入口，简化导入路径
- **改进辅助脚本功能**
  - `scripts/clean.sh`: 添加命令行参数支持，支持单独清理 store 或旧版本
  - `scripts/update.sh`: 添加根据主机名自动选择构建配置的功能
  - `scripts/setup-disk.sh`: 添加完整的命令行参数支持，支持可选加密、自定义仓库 URL、传递主机类型/窗口管理器/桌面 Shell 参数
  - `scripts/wallpaper-color.sh`: 改进 bash 检测逻辑，支持项目壁纸目录和用户壁纸目录，添加颜色输出日志函数，支持更多壁纸格式（jpg、jpeg、png、gif、webp）
- **添加壁纸文件夹**
  - 创建 `wallpapers/` 目录用于存放壁纸文件
  - 默认壁纸为中国风雄伟山河深色调（`default.jpg`）
  - 更新 `home/common/shell.nix`，自动复制壁纸目录到用户目录
  - 更新 `modules/desktops/unified-theme.nix`，添加壁纸目录自动创建支持
  - 更新 `scripts/wallpaper-color.sh`，支持从项目目录读取壁纸，添加对 Noctalia-Shell 和 DMS-Shell 的壁纸设置和配色支持
- **添加壁纸变化监听服务**
  - 创建 `scripts/wallpaper-watcher.sh` 脚本，监听壁纸变化
  - 创建 `home/common/wallpaper-watcher.nix` Home Manager 模块
  - 支持通过 Noctalia-Shell/DMS-Shell 界面选择壁纸后自动触发配色更新
- 根据 NixOS 26.05 语法检查所有 Nix 代码
- **优化鼠标侧键配置**：在 Hyprland 中添加 `pass` 绑定（Button 8/9），让应用程序（如 Nemo、Firefox）能够正确处理后退/前进功能
- **更新 Qt 相关包名**：适配 NixOS 26.05 包库（`adwaita-qt` → `qt6Packages.adwaita-qt`，`qt6-multimedia` → `qt6Packages.qtmultimedia`，`fcitx5-qt` → `qt6Packages.fcitx5-qt`）
- **创建鼠标配置模块**：`modules/hardware/mouse.nix`，记录鼠标按钮编号说明和侧键处理策略

### Fixed

- 修复 fcitx5 包名问题：`fcitx5-chinese-addons` 和 `fcitx5-configtool` 需要 `qt6Packages` 前缀
- 修复鼠标侧键 Button 8/9 未生效问题：在 Hyprland 中添加 `pass` 绑定传递事件给应用程序
- 修复 `home/common/shell.nix` 中 `exa` 命令别名，改为 `eza`
- 修复 `qtwayland` 包引用问题，需要 `kdePackages` 前缀
- 修复 `polkit-kde-agent` 包引用问题，需要 `kdePackages.polkit-kde-agent-1`
- 修复代码中 `youruser` 占位符问题
- 修复 install.sh 与 flake.nix 主机类型配置冲突问题
- **修复 `modules/system/fonts.nix` 中无效的 `fonts.fontconfig.extraFonts` 选项**：改用 `fonts.fontconfig.localConf` 添加 XML 字体别名映射，并将字体包从 `environment.systemPackages` 移到 `fonts.packages`
- **修复 `install.sh` 生成配置不完整问题**：添加 `polkitAgent` 选项支持，初始化 `POWER_MANAGEMENT` 变量避免未定义行为
- **修复 `modules/desktops/unified-theme.nix` 中重复的 `environment.systemPackages` 定义**：合并为一个 `lib.mkAfter` 块，避免 NixOS 配置合并冲突
- **修复 `home/common/dev-lsp.nix` 中无效的 `programs.language-servers` 选项**：移除不存在的 Home Manager 选项，仅保留 `home.packages`
- **修复 `home/common/input.nix` 中无效的 `programs.fcitx5` 选项**：移除不存在的 Home Manager 选项，保留 `xdg.configFile` RIME 配置
- **修复 `modules/desktops/unified-theme.nix` 中重复的 `environment.etc` 定义**：将壁纸目录和 GTK/Qt 配置文件合并到同一个 `environment.etc` 块中

### Removed

- 移除 Stylix 主题框架
- 移除 Xorg 工具（xorg.xinit、xorg.xrandr）
- 移除非必要的显示管理器（保留 SDDM）
- 移除 overlays 目录（未使用）
- 移除所有硬件配置模板文件（改为安装时自动生成）

## [2026-06-10]

### Added

- 项目初始化：基于 NixOS 26.05 的现代化配置仓库
- Hyprland 0.55.2 窗口管理器配置（通过 hyprnix 管理）
- Niri 窗口管理器配置
- DMS-Shell 轻量级桌面 Shell
- Noctalia-Shell 现代化桌面集成 Shell
- Fcitx5 + RIME 输入法配置（使用 oh-my-rime）
- GTK/Qt 主题和图标统一配置
- 交互式安装脚本（scripts/install.sh）
- SDDM 显示管理器配置（仅 Wayland 模式）
- 用户级工具配置（neovim、emacs、yazi、vlc、eza、bat）
- UEFI 引导配置（systemd-boot，保留3个开机选项）
- 模块化架构：系统配置、用户配置、硬件配置分离
- 国内镜像源配置（中科大、清华、北外镜像）加速二进制包下载
- 安装脚本支持自动生成硬件配置

### Changed

- 许可证从 MIT 变更为 GNU GPL v3.0

### Fixed

- 修复 `home/common/input.nix` 中重复的包定义问题

## [2026-06-09]

### Added

- 完成安装脚本（scripts/install.sh）开发
  - 支持输入用户名、主机名、Git 信息
  - 支持选择主机类型（Desktop/Laptop/Server）
  - 支持选择窗口管理器（Hyprland/Niri）
  - 支持选择桌面 Shell（DMS-Shell/Noctalia-Shell）
  - 自动生成主机配置和用户配置

### Changed

- 优化项目结构，模块化拆分配置文件
- 更新 flake.nix 使用 `mkHost` 函数统一管理主机配置

## [2026-06-08]

### Added

- 配置 Hyprland 使用 Lua 语法
- 添加 Niri 窗口管理器模块
- 添加 DMS-Shell 和 Noctalia-Shell 模块
- 添加主题统一配置（GTK/Qt/图标）

### Changed

- 移除 stylix 主题框架

## [2026-06-07]

### Added

- 初始化项目结构
- 添加基础系统模块（common.nix、security.nix、network.nix）
- 添加硬件模块（蓝牙、输入法）
- 添加 Home Manager 用户配置