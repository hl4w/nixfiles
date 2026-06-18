# HL4W Migration Guide

## From Old Configuration

### Step 1: Backup Existing Config

```bash
# List existing generations
sudo nixos-rebuild list-generations
sudo nix-env --list-generations

# Backup important dotfiles
cp -r ~/.config ~/.config.backup
cp -r ~/.local/share ~/.local/share.backup
```

### Step 2: Run Installation Script

```bash
# Clone repository
# Chinese users recommended to use Gitee mirror:
git clone https://gitee.com/hl4w/nixfiles.git
# International users use GitHub:
# git clone https://github.com/hl4w/nixfiles.git
cd nixfiles

# Run installation script
chmod +x scripts/install.sh
./scripts/install.sh
```

The script will guide you through:
1. Enter username, hostname, Git info
2. Select host type (Desktop/Laptop/Server)
3. Select window manager (Hyprland/Niri)
4. Select desktop shell (DMS-Shell/Noctalia-Shell)
5. **Optional: Auto-generate hardware configuration**

### Step 3: Generate Hardware Configuration

> **Note**: This project no longer includes predefined hardware configuration files. They must be generated during installation.

The installation script can optionally generate hardware configuration automatically. If not selected, run manually:

On the target machine:
```bash
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
```

Or for a fresh install:
```bash
sudo nixos-generate-config --root /mnt
```

### Step 4: Update UUIDs

Update `hardware-configuration.nix` with actual values from:
```bash
lsblk -f
```

Ensure:
- Root partition `device` points to the correct disk/partition
- Swap partition is properly configured
- Boot partition mount point is correct

### Step 5: Migrate User Configuration

Copy your dotfiles to the appropriate `home/common/` modules or create host-specific overrides in `home/hosts/`.

Key files to migrate:
- Shell config: `~/.zshrc` → `home/common/shell.nix`
- Editor config: `~/.config/nvim` → `home/common/editor.nix`
- Git config: `~/.gitconfig` → `home/common/git.nix`

### Step 6: Test Build

```bash
nix build .#hostname
```

### Step 7: Deploy

```bash
sudo nixos-rebuild switch --flake .#hostname
```

### Step 8: Update Home Manager

```bash
home-manager switch --flake .#username@hostname
```

## Upgrading to New NixOS Version

### Step 1: Update flake.nix

```nix
inputs = {
  # Update to new version
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  
  # Update home-manager to match
  home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

### Step 2: Update Flake Lock

```bash
# Update all inputs
nix flake update

# Or update specific input
nix flake update nixpkgs
```

### Step 3: Build and Deploy

```bash
# Test build
nix build .#hostname

# Deploy to system
sudo nixos-rebuild switch --flake .#hostname

# Update Home Manager
home-manager switch --flake .#username@hostname
```

## Package Changes

### Replaced Packages

| Old Package | New Package | Reason |
|-------------|-------------|--------|
| `exa` | `eza` | exa is deprecated, eza is the maintained fork |
| `thunar` | `nemo` | nemo supports PDF/image preview |
| `wofi` | `rofi` | rofi has better Wayland support |
| `waybar` | WM built-in | Hyprland/Niri have built-in status bars |

### kdePackages/qt6Packages Prefix (NixOS 26.05)

Some packages now require `kdePackages` or `qt6Packages` prefix:

```nix
# Old (NixOS < 26.05)
qtwayland
fcitx5-configtool
fcitx5-chinese-addons

# New (NixOS 26.05)
qt6Packages.qtwayland
qt6Packages.fcitx5-configtool
qt6Packages.fcitx5-chinese-addons
kdePackages.polkit-kde-agent-1
```

### Package Classification

Packages are now classified by level:

| Level | Packages | Location |
|-------|----------|----------|
| System | git, wget, curl, nil, tmux, zsh, tree, highlight, nixpkgs-fmt | `modules/system/default.nix` |
| User | fastfetch, btop, eza, bat, fzf, fd, ripgrep, yazi, zoxide, dust, duf, tokei, hyperfine, procs | `home/common/cli.nix` |
| Desktop | rofi, nemo, nemo-extensions, evince, eog, alacritty/kitty/foot (foot default), pywal, vlc | `home/common/apps.nix` |
| Development | clangd, clang-tools, cmake, ninja, gdb, lldb, go, gopls, python3, pyright, rustc, rust-analyzer, rustfmt, cargo | `home/common/dev-lsp.nix` |
| Office | wps-office-cn, nextcloud-client | `home/common/apps.nix` |

### CLI Tools Migration

If you were using custom CLI tool configurations, migrate to the new `home/common/cli.nix` module:

1. **New Tools**: Yazi, Zoxide, dust, duf, tokei, hyperfine, procs, starship are now included by default
2. **Configuration Location**: CLI tools are now managed in `home/common/cli.nix`
3. **Zoxide Integration**: Auto-configured for smart directory navigation (`z` command)
4. **Yazi Integration**: Zoxide support enabled, use `z` command after pressing `Ctrl+G` to open shell
5. **FZF Integration**: Configured in `home/common/cli.nix` with Zsh integration

**CLI Tools Overview**:

| Tool | Description | Replacement For |
|------|-------------|-----------------|
| `eza` | Enhanced ls | `ls` |
| `bat` | Enhanced cat (syntax highlighting) | `cat` |
| `fd` | Fast file finder | `find` |
| `rg` (ripgrep) | Fast text search | `grep` |
| `fzf` | Fuzzy search | - |
| `yazi` | Terminal file manager | `ranger`, `nnn` |
| `zoxide` | Smart directory navigation | `cd` |
| `fastfetch` | System info display | `neofetch` |
| `btop` | System resource monitor | `htop` |
| `dust` | Disk usage analysis | `du` |
| `duf` | Disk space viewer | `df` |
| `tokei` | Code statistics | `cloc` |
| `hyperfine` | Command performance testing | - |
| `procs` | Enhanced process viewer | `ps` |
| `starship` | Cross-shell prompt | - |

### Lix Migration

If you were using native Nix, this configuration has migrated to Lix:

1. **Configuration Location**: `modules/system/default.nix`
2. **Auto-override**: Uses overlay to ensure Nix-dependent tools also use Lix
3. **Verification**:
```bash
nix --version
# Output: nix (Lix, like Nix) 2.x.x
```

## Display Changes

### Wayland Only

This configuration now only supports Wayland/Xwayland:

- X11 display is disabled (`services.xserver.enable = false`)
- SDDM runs in Wayland mode
- Xorg tools removed (xorg.xinit, xorg.xrandr)
- Use Wayland-native tools (wlr-randr)

### SDDM Configuration

```nix
services.sddm = {
  enable = true;
  wayland.enable = true;  # Wayland mode
  displayServer = "wayland";
};
```

## Boot Configuration

### UEFI with systemd-boot

GRUB is replaced with systemd-boot:

```nix
boot.loader = {
  systemd-boot = {
    enable = true;
    configurationLimit = 3;  # Keep 3 boot entries
  };
  efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };
};
```

## Chinese Mirror Configuration

Add Chinese mirrors for faster binary downloads:

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

## Wallpaper Auto-color Migration

If you were using a custom wallpaper setup, migrate to the new auto-color system:

1. **Wallpaper directory**: The system automatically creates `~/.wallpapers/` and syncs from project `wallpapers/`

2. **Set wallpaper and apply colors**:
```bash
# Set specified wallpaper
wp-color -s your-wallpaper.png

# Or use default wallpaper
wp-color -s
```

3. **Automatic color watcher**: The system monitors wallpaper changes automatically. When you select a wallpaper via Noctalia-Shell/DMS-Shell GUI, colors will be updated automatically.

4. The system will automatically:
   - Extract colors from the wallpaper using pywal
   - Apply colors to terminal, shell, editors, and Shell
   - Maintain color consistency with GTK/Qt themes
   - Monitor wallpaper changes and auto-update colors

## Day/Night Theme Switching Migration

If you were using manual theme switching, migrate to the new unified theme system:

1. Ensure `unified-theme.nix` is imported in your host configuration:
```nix
imports = [
  ../modules/desktops/unified-theme.nix
];
```

2. Configure theme mode in your host configuration:
```nix
desktop.unified-theme = {
  themeMode = "auto";    # dark/light/auto
  dayStart = 6;          # Day start hour
  nightStart = 18;       # Night start hour
};
```

3. Use the new theme commands:
```bash
# Auto-switch based on time
theme-auto

# Force dark mode
theme-dark

# Force light mode
theme-light
```

4. The system will:
   - Automatically switch between Adwaita (light) and Adwaita-dark (dark)
   - Switch between Papirus and Papirus-Dark icons
   - Apply theme to GTK, Qt, Shell, and SDDM
   - Support manual overrides via command line

## Common Issues

### Missing Hardware Drivers

Check `hardware-configuration.nix` and ensure all necessary kernel modules are included.

### Permission Denied

Ensure your user is in the `wheel` group and has sudo access.

### Hyprland Issues

- Check that `xdg-desktop-portal-hyprland` is installed
- Ensure SDDM is running in Wayland mode
- Verify `qt6Packages.qtwayland` is installed

### Niri Issues

- Ensure Wayland session is properly configured
- Check SDDM session file exists
- Verify `xdg-desktop-portal-niri` is installed

### kdePackages Not Found

Update package references to use `kdePackages` or `qt6Packages` prefix:

```nix
# Check current references
grep -r "qtwayland\|fcitx5-configtool\|fcitx5-chinese-addons\|polkit-kde-agent" modules/ home/

# Update to proper prefix
qt6Packages.qtwayland
qt6Packages.fcitx5-configtool
qt6Packages.fcitx5-chinese-addons
kdePackages.polkit-kde-agent-1
```

### Binary Download Slow

Ensure Chinese mirrors are configured:

```bash
nix show-config | grep substituters
```

If mirrors are not showing, add them to `flake.nix` and `modules/system/default.nix`.

## Post-Migration Checklist

- [ ] Hardware configuration generated and UUIDs updated
- [ ] User dotfiles migrated to Home Manager modules
- [ ] Build succeeds: `nix build .#hostname`
- [ ] System deployed: `sudo nixos-rebuild switch --flake .#hostname`
- [ ] Home Manager updated: `home-manager switch --flake .#username@hostname`
- [ ] Window manager starts correctly
- [ ] Input method works (Fcitx5 + RIME)
- [ ] Audio works (PipeWire)
- [ ] Chinese mirrors configured and working
- [ ] Wallpaper auto-color system configured (optional)
- [ ] Day/night theme switching configured (optional)