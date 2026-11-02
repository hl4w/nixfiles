# HL4W（Hack Linux for Workflow） - Nixfiles for NixOS

**Version: v0.0.6**

A modern configuration repository built on NixOS 26.05, featuring a deeply optimized Hyprland & Niri desktop suite with native compatibility for Noctalia & DMS Shell desktop components. Powered by Nix Flakes and Home Manager, it unifies system and user environment management across multiple devices.

## Features

- **Hyprland** / **Niri**: Wayland window managers [(Details)](docs/architecture_en.md) [(Shortcuts)](docs/shortcuts_en.md)
- **Modular Architecture**: Clear directory structure with a strict system/user boundary, easy to extend and maintain [(Architecture)](docs/architecture_en.md)
- **Multi-host Support**: Unified management for desktop, laptop, and server, with modules assembled per host type [(Architecture)](docs/architecture_en.md)
- **One-command Install**: `setup-disk.sh` handles GPT partitioning, LUKS2 + LVM encryption, formatting, mounting and config deployment; `install.sh` initializes the host configuration [(Scripts](#scripts))
- **GPU Auto-Detection**: Automatically identifies NVIDIA/AMD/Intel GPUs during installation, intelligently configures drivers and kernel parameters [(Architecture)](docs/architecture_en.md)
- **Unified Theming**: Consistent GTK/Qt/Hyprland/Niri/Shell/SDDM/Fcitx5 color schemes (Catppuccin) [(Architecture)](docs/architecture_en.md)
- **Wallpaper Auto-color**: Uses pywal to extract colors from wallpapers, with a watcher service that follows wallpaper changes [(Architecture)](docs/architecture_en.md)
- **Day/Night Theme Switching**: Automatic light/dark theme switching based on time [(Architecture)](docs/architecture_en.md)
- **Flexible Desktop Configuration**: Dynamic window manager (Hyprland/Niri), desktop shell (DMS/Noctalia) and polkit agent (KDE/Hyprland) selection [(Architecture)](docs/architecture_en.md)
- **WPS Office CN**: Chinese version office suite with better Chinese support [(Architecture)](docs/architecture_en.md)
- **Chinese Fonts**: Full support for Noto CJK, Source Han, WenQuanYi fonts [(Architecture)](docs/architecture_en.md)
- **Chinese Input Method**: Fcitx5 + RIME with oh-my-rime (Mint Pinyin) framework, supporting pinyin, double pinyin, terra pinyin, plus a Catppuccin theme [(Architecture)](docs/architecture_en.md)
- **Default Terminal**: foot (lightweight high-performance terminal), with kitty and alacritty also supported [(Architecture)](docs/architecture_en.md)
- **Modern CLI Toolset**: eza, bat, fd, rg, fzf, yazi (terminal file manager), zoxide (smart navigation), fastfetch, btop, dust, duf, tokei, hyperfine, procs replacing traditional tools
- **Multi-language Development Support**: Complete development environment for Go, Python, Rust and C/C++ with LSP support [(Architecture)](docs/architecture_en.md)
- **Modular Audio Configuration**: Unified audio module (rtkit + PipeWire + PulseAudio compatibility)
- **Optimized Boot Configuration**: systemd-boot + Plymouth quiet boot with reduced logging
- **Lix High-Performance Nix**: Uses Lix instead of native Nix for better performance
- **Spell Checker Support**: System-level nuspell engine with English dictionary support
- **Nextcloud Client**: Cloud file sync support [(Architecture)](docs/architecture_en.md)
- **Mouse Side Buttons**: Back/forward navigation in Nemo, Firefox and other applications [(Architecture)](docs/architecture_en.md)
- **NixOS 26.05 Compatibility**: Uses kdePackages for KDE package version compatibility, hardware.graphics (NixOS 24.11+) replaces hardware.opengl
- **Chinese Mirror Acceleration**: Pre-configured with USTC, Tsinghua, BFSU mirrors for faster binary downloads
- **Wallpaper Repository**: Full wallpaper collection available at `https://github.com/hl4w/wallpaper.git`

## Requirements

| Item | Requirement |
|------|-------------|
| System | Fresh installs should boot the NixOS 26.05 installer image (ISO) |
| Nix | Flakes enabled (`experimental-features = nix-command flakes`) |
| Privileges | `setup-disk.sh` requires root; `install.sh` needs permission to run `sudo nixos-generate-config` |
| Disk | The target disk will be **completely erased**, back up your data first |

## Quick Start

### Option 1: Fresh install (boot from NixOS ISO)

```bash
# 1. Clone repository (Gitee mirror for China, GitHub elsewhere)
git clone https://gitee.com/hl4w/nixfiles.git
# git clone https://github.com/hl4w/nixfiles.git
cd nixfiles

# 2. Partition + encrypt + deploy config in one command (wipes the target disk)
sudo ./scripts/setup-disk.sh -T desktop -W hyprland -S dms /dev/nvme0n1 my-hostname myuser

# Partition names are derived automatically for devices such as /dev/sda
# To skip disk encryption (not recommended): add -c before the positional arguments

# 3. Review the generated hardware configuration, then install
sudo nixos-install --flake .#my-hostname

# 4. Reboot into the new system
reboot
```

`setup-disk.sh` runs: GPT partition table → EFI partition → LUKS2 container → LVM (root/swap/home) → formatting → mounting → repository clone → `install.sh` host generation. Without encryption it skips LUKS/LVM, splits the disk 60%/40% between `/` and `/home`, and creates a swapfile.

### Option 2: Existing NixOS system, host configuration only

```bash
git clone https://gitee.com/hl4w/nixfiles.git
cd nixfiles

chmod +x scripts/install.sh
./scripts/install.sh
```

Interactive mode asks for username, hostname, host type, window manager, desktop shell and polkit agent. Everything can also be supplied as arguments:

```bash
./scripts/install.sh -y -U myuser -H my-hostname -T desktop -W hyprland -S dms -P kde
```

> `-y` enables non-interactive mode: missing required arguments cause an immediate error instead of blocking on prompts.

### Option 3: Manual deployment

```bash
# 1. Clone repository
git clone https://gitee.com/hl4w/nixfiles.git
cd nixfiles

# 2. Generate flake.lock (locks dependencies, including the oh-my-rime input)
nix flake update

# 3. Create host configuration directory (copy template)
cp -r templates/host-template hosts/<hostname>

# 4. Generate hardware configuration
#    Inside the installer with the target root mounted at /mnt, pass --root /mnt
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix

# 5. Edit flake.nix and add the host entry in nixosConfigurations
# my-hostname = mkHost "my-hostname";

# 6. Create Home Manager user configuration
touch home/hosts/<hostname>.nix

# 7. Test build (nixosConfigurations requires the full attribute path)
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# 8. Deploy system
sudo nixos-rebuild switch --flake .#<hostname>

# 9. Update user configuration
home-manager switch --flake .#<username>@<hostname>
```

[(Detailed Installation Guide)](docs/migration_en.md)

## Scripts

Every script ships in two variants (`*.sh` in Chinese, `*_en.sh` in English).

| Script | Purpose | Common options |
|--------|---------|----------------|
| `setup-disk.sh <disk> <host> <user>` | Fresh install: partitioning, LUKS2+LVM encryption, format/mount, config deployment | `-y` non-interactive, `-c` disable encryption, `-r` repository URL, `-T/-W/-S` host type / window manager / desktop shell |
| `install.sh` | Initialize host config: generate `hosts/<host>` and `home/hosts/<host>.nix`, hardware config, replace placeholders | `-y` non-interactive, `-U` username, `-H` hostname, `-G/-E` Git user/email, `-T/-W/-S/-P` component selection, `-N` flake name |
| `update.sh` | Update flake inputs and rebuild the system | `-H` hostname (auto-detected by default) |
| `clean.sh` | Clean the Nix store and old generations | `-s` store only, `-g` generations only, `-a` all (default), `-y` auto-confirm |
| `setup-direnv.sh` | Configure direnv automatic environment loading | `-y` non-interactive |
| `wallpaper-color.sh` | Extract colors from wallpapers and apply theming | `-w` wallpaper path, `-s` set by name, `-d` random, `-l` list, `-c` current colors, `-a` apply colors only |
| `wallpaper-watcher.sh` | Watch wallpaper changes and refresh colors (invoked by the systemd user service) | `WATCH_INTERVAL` environment variable sets the polling interval (seconds, default 5) |

> All scripts use `set -euo pipefail` with explicit argument validation; `setup-disk.sh` verifies root privileges and the block device before performing any destructive operation.

## Documentation

See the `docs/` directory for detailed documentation:

| Document | Description |
|----------|-------------|
| `docs/CHANGELOG.md` / `docs/CHANGELOG_EN.md` | Changelog (Chinese / English) |
| `docs/architecture.md` / `docs/architecture_en.md` | Architecture overview, module structure, configuration flow |
| `docs/shortcuts.md` / `docs/shortcuts_en.md` | Keyboard shortcut reference (Hyprland / Niri) |
| `docs/faq.md` / `docs/faq_en.md` | Frequently asked questions and troubleshooting |
| `docs/migration.md` / `docs/migration_en.md` | Migration and installation guide |

## Project Structure

```
.
├── hosts/                    # Host configurations (system-level, native NixOS options)
│   ├── common/               # Shared system config (default / desktop-common / hardware-common)
│   ├── desktop/              # Desktop host configuration
│   ├── laptop/               # Laptop host configuration
│   └── server/               # Server host configuration
├── modules/                  # System modules
│   ├── boot/                 # Boot config (systemd-boot, Plymouth)
│   ├── desktops/             # Desktop environments (hyprland, niri, sddm, shell-dms, shell-noctalia, unified-theme)
│   ├── hardware/             # Hardware config (nvidia, sound, bluetooth, firmware, mouse)
│   ├── input-method/         # Input method (Fcitx5 + RIME + oh-my-rime + Catppuccin theme)
│   ├── services/             # Services (network, security, virtualisation)
│   └── system/               # System base (fonts, etc.)
├── home/                     # Home Manager user configurations (user-level, HM-only options)
│   ├── common/               # Shared user modules (apps, cli, dev-lsp, editor, git, shell,
│   │                         #   input, hyprland, niri, unified-theme, wallpaper-watcher)
│   └── hosts/                # Host-specific user configurations (desktop / laptop / server)
├── scripts/                  # Install and maintenance scripts (Chinese + English pairs)
├── templates/                # Template files
│   └── host-template/        # Host configuration template
├── wallpapers/               # Wallpaper files
├── docs/                     # Documentation
├── secrets/                  # Sensitive configurations (not version controlled)
├── .github/                  # CI workflows
└── flake.nix                 # Entry point (run `nix flake update` to generate flake.lock before first build)
```

### Configuration Layers

| Directory | Level | Description |
|-----------|-------|-------------|
| `hosts/` | System-level | NixOS system configuration, managed by root, native NixOS options only |
| `modules/` | System-level | Reusable NixOS modules imported by multiple hosts |
| `home/` | User-level | Home Manager user configuration, managed by regular users, HM-only options |

> System and user layers are strictly separated: Home Manager options such as `gtk.*`, `xdg.*` and `wayland.windowManager.*` must not appear in `modules/`; conversely, system options such as `environment.systemPackages` and `services.*` should not be written into `home/`.

## Management Commands

### System Updates

After installation, if you modify any Nix modules, you can directly update the system using the following commands:

```bash
# Update system directly (recommended)
sudo nixos-rebuild switch --flake .#<hostname>

# Update Home Manager user configuration
home-manager switch --flake .#<username>@<hostname>

# Update flake inputs (upgrade dependency versions)
nix flake update

# One-click update using script (includes flake update and system rebuild)
./scripts/update.sh

# Clean old generations and the Nix store
./scripts/clean.sh

# Check configuration (no build)
nix flake check

# Test build (no deployment, full attribute path)
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

**Notes**:

- After modifying system modules in `modules/`, run `sudo nixos-rebuild switch --flake .#<hostname>` to apply changes
- After modifying user configurations in `home/`, run `home-manager switch --flake .#<username>@<hostname>` to apply changes
- Use `nix flake update` to update all input dependencies (nixpkgs, home-manager, oh-my-rime, etc.)
- Verify configurations with `nix flake check` or the full-attribute-path `nix build` before deployment
- `nix build .#<hostname>` only works when the flake exposes `packages.<system>.<hostname>`; this repository uses `nixosConfigurations`, so use the full attribute path above

[(Script Usage Documentation)](docs/architecture_en.md)

## FAQ

Having issues? Check [(FAQ)](docs/faq_en.md)

## License

GNU General Public License v3.0
