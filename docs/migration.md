# 迁移指南

## 从旧配置迁移

### 步骤 1：备份现有配置

```bash
# 列出现有代次
sudo nixos-rebuild list-generations
sudo nix-env --list-generations

# 备份重要的配置文件
cp -r ~/.config ~/.config.backup
cp -r ~/.local/share ~/.local/share.backup
```

### 步骤 2：运行安装脚本

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
5. **可选：自动生成硬件配置**

### 步骤 3：生成硬件配置

> **注意**：此项目不再包含预定义的硬件配置文件。必须在安装过程中生成。

安装脚本可以选择性地自动生成硬件配置。如果未选择，手动运行：

在目标机器上：
```bash
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
```

或在全新安装时：
```bash
sudo nixos-generate-config --root /mnt
```

### 步骤 4：更新 UUID

使用以下命令获取实际值并更新 `hardware-configuration.nix`：
```bash
lsblk -f
```

确保：
- 根分区 `device` 指向正确的磁盘/分区
- 交换分区配置正确
- 启动分区挂载点正确

### 步骤 5：迁移用户配置

将您的配置文件复制到相应的 `home/common/` 模块，或在 `home/hosts/` 中创建主机特定的覆盖配置。

需要迁移的关键文件：
- Shell 配置：`~/.zshrc` → `home/common/shell.nix`
- 编辑器配置：`~/.config/nvim` → `home/common/editor.nix`
- Git 配置：`~/.gitconfig` → `home/common/git.nix`

### 步骤 6：测试构建

```bash
nix build .#hostname
```

### 步骤 7：部署

```bash
sudo nixos-rebuild switch --flake .#hostname
```

### 步骤 8：更新 Home Manager

```bash
home-manager switch --flake .#username@hostname
```

## 升级到新版本 NixOS

### 步骤 1：更新 flake.nix

```nix
inputs = {
  # 更新到新版本
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  
  # 更新 home-manager 以匹配版本
  home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

### 步骤 2：更新 Flake 锁定文件

```bash
# 更新所有输入
nix flake update

# 或更新特定输入
nix flake update nixpkgs
```

### 步骤 3：构建并部署

```bash
# 测试构建
nix build .#hostname

# 部署到系统
sudo nixos-rebuild switch --flake .#hostname

# 更新 Home Manager
home-manager switch --flake .#username@hostname
```

## 包变更

### 替换的包

| 旧包 | 新包 | 原因 |
|------|------|------|
| `exa` | `eza` | exa 已弃用，eza 是维护的分支 |
| `thunar` | `nemo` | nemo 支持 PDF/图片预览 |
| `wofi` | `rofi` | rofi 对 Wayland 支持更好 |
| `waybar` | 窗口管理器内置 | Hyprland/Niri 有内置状态栏 |

### kdePackages/qt6Packages 前缀（NixOS 26.05）

一些包现在需要 `kdePackages` 或 `qt6Packages` 前缀：

```nix
# 旧版（NixOS < 26.05）
qtwayland
fcitx5-configtool
fcitx5-chinese-addons

# 新版（NixOS 26.05）
qt6Packages.qtwayland
qt6Packages.fcitx5-configtool
qt6Packages.fcitx5-chinese-addons
kdePackages.polkit-kde-agent-1
```

### 包分类

包现在按级别分类：

| 级别 | 包 | 位置 |
|------|------|------|
| 系统 | git, wget, curl, nil, tmux, zsh, tree, highlight, nixpkgs-fmt | `modules/system/default.nix` |
| 用户 | fastfetch, btop, eza, bat, fzf, fd, ripgrep, yazi, zoxide, dust, duf, tokei, hyperfine, procs | `home/common/cli.nix` |
| 桌面 | rofi, nemo, nemo-extensions, evince, eog, alacritty/kitty/foot（默认 foot）, pywal, vlc | `home/common/apps.nix` |
| 开发 | clangd, clang-tools, cmake, ninja, gdb, lldb, go, gopls, python3, pyright, rustc, rust-analyzer, rustfmt, cargo | `home/common/dev-lsp.nix` |
| 办公 | wps-office-cn, nextcloud-client | `home/common/apps.nix` |

### CLI 工具迁移

如果您之前使用自定义 CLI 工具配置，请迁移到新的 `home/common/cli.nix` 模块：

1. **新增工具**: Yazi、Zoxide、dust、duf、tokei、hyperfine、procs 已默认包含
2. **配置位置**: CLI 工具现在统一在 `home/common/cli.nix` 中管理
3. **Zoxide 集成**: 已自动配置，支持智能目录导航
4. **Yazi 集成**: 已配置 Zoxide 支持，按 `Ctrl+G` 打开 shell 后可用 `z` 命令跳转

### Lix 迁移

如果您之前使用原生 Nix，本配置已迁移到 Lix：

1. **配置位置**: `modules/system/default.nix`
2. **自动覆盖**: 使用 overlay 确保依赖 Nix 的工具也使用 Lix
3. **验证**:
```bash
nix --version
# 输出: nix (Lix, like Nix) 2.x.x
```

## 显示变更

### 仅支持 Wayland

此配置现在仅支持 Wayland/Xwayland：

- X11 显示已禁用（`services.xserver.enable = false`）
- SDDM 以 Wayland 模式运行
- 移除 Xorg 工具（xorg.xinit, xorg.xrandr）
- 使用 Wayland 原生工具（wlr-randr）

### SDDM 配置

```nix
services.sddm = {
  enable = true;
  wayland.enable = true;  # Wayland 模式
  displayServer = "wayland";
};
```

## 启动配置

### UEFI 与 systemd-boot

GRUB 已被 systemd-boot 替换：

```nix
boot.loader = {
  systemd-boot = {
    enable = true;
    configurationLimit = 3;  # 保留 3 个启动项
  };
  efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };
};
```

## 中国镜像配置

添加中国镜像以加快二进制下载：

```nix
nixConfig = {
  substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.bfsu.edu.cn/nix-channels/store"
    "https://cache.nixos.org"
  ];
};
```

## 壁纸自动取色迁移

如果您之前使用自定义壁纸设置，请迁移到新的自动取色系统：

1. **壁纸目录**：系统自动创建 `~/.wallpapers/` 并从项目 `wallpapers/` 同步

2. **设置壁纸并应用颜色**：
```bash
# 设置指定壁纸
wp-color -s your-wallpaper.png

# 或使用默认壁纸
wp-color -s
```

3. **自动颜色监听器**：系统自动监控壁纸变化。当您通过 Noctalia-Shell/DMS-Shell GUI 选择壁纸时，颜色会自动更新。

4. 系统会自动：
   - 使用 pywal 从壁纸提取颜色
   - 将颜色应用到终端、Shell、编辑器和桌面 Shell
   - 保持与 GTK/Qt 主题的颜色一致性
   - 监控壁纸变化并自动更新颜色

## 日夜主题切换迁移

如果您之前使用手动主题切换，请迁移到新的统一主题系统：

1. 确保 `unified-theme.nix` 已在主机配置中导入：
```nix
imports = [
  ../modules/desktops/unified-theme.nix
];
```

2. 在主机配置中配置主题模式：
```nix
desktop.unified-theme = {
  themeMode = "auto";    # dark/light/auto
  dayStart = 6;          # 白天开始时间
  nightStart = 18;       # 夜晚开始时间
};
```

3. 使用新的主题命令：
```bash
# 根据时间自动切换
theme-auto

# 强制深色模式
theme-dark

# 强制浅色模式
theme-light
```

4. 系统会：
   - 自动在 Adwaita（浅色）和 Adwaita-dark（深色）之间切换
   - 在 Papirus 和 Papirus-Dark 图标之间切换
   - 将主题应用到 GTK、Qt、Shell 和 SDDM
   - 支持通过命令行手动覆盖

## 常见问题

### 缺少硬件驱动

检查 `hardware-configuration.nix` 并确保包含所有必要的内核模块。

### 权限被拒绝

确保您的用户在 `wheel` 组中并有 sudo 访问权限。

### Hyprland 问题

- 检查 `xdg-desktop-portal-hyprland` 是否已安装
- 确保 SDDM 以 Wayland 模式运行
- 验证 `qt6Packages.qtwayland` 是否已安装

### Niri 问题

- 确保 Wayland 会话配置正确
- 检查 SDDM 会话文件是否存在
- 验证 `xdg-desktop-portal-niri` 是否已安装

### kdePackages 未找到

更新包引用以使用 `kdePackages` 或 `qt6Packages` 前缀：

```nix
# 检查当前引用
grep -r "qtwayland\|fcitx5-configtool\|fcitx5-chinese-addons\|polkit-kde-agent" modules/ home/

# 更新为正确的前缀
qt6Packages.qtwayland
qt6Packages.fcitx5-configtool
qt6Packages.fcitx5-chinese-addons
kdePackages.polkit-kde-agent-1
```

### 二进制下载缓慢

确保配置了中国镜像：

```bash
nix show-config | grep substituters
```

如果未显示镜像，请将其添加到 `flake.nix` 和 `modules/system/default.nix`。

## 迁移后检查清单

- [ ] 硬件配置已生成并更新 UUID
- [ ] 用户配置文件已迁移到 Home Manager 模块
- [ ] 构建成功：`nix build .#hostname`
- [ ] 系统已部署：`sudo nixos-rebuild switch --flake .#hostname`
- [ ] Home Manager 已更新：`home-manager switch --flake .#username@hostname`
- [ ] 窗口管理器正确启动
- [ ] 输入法正常工作（Fcitx5 + RIME）
- [ ] 音频正常工作（PipeWire）
- [ ] 中国镜像已配置并正常工作
- [ ] 壁纸自动取色系统已配置（可选）
- [ ] 日夜主题切换已配置（可选）