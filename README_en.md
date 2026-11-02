# HL4W (Hack Linux for Workflow) - Nixfiles for NixOS

**Version: v0.0.6**

A modern configuration repository built on NixOS 26.05, featuring a deeply tuned Hyprland & Niri desktop suite with native support for DMS Shell and Noctalia Shell. Nix Flakes + Home Manager manage system and user environments across multiple machines.

## Features

### Desktop & Appearance

- **Hyprland** / **Niri**: Wayland window managers [(details)](docs/architecture.md) [(shortcuts)](docs/shortcuts.md)
- **Selectable desktop shell**: native support for DMS Shell and Noctalia Shell, freely combined with KDE / Hyprland polkit agents [(architecture)](docs/architecture.md)
- **Unified theming**: GTK / Qt / Hyprland / Niri / Shell / SDDM / Fcitx5 all themed with Catppuccin [(architecture)](docs/architecture.md)
- **Wallpaper auto-coloring**: pywal extracts colors from the wallpaper and a watcher service follows wallpaper changes [(architecture)](docs/architecture.md)
- **Day/night theme switching**: automatically switches between light and dark styles by time of day [(architecture)](docs/architecture.md)

### Installation & System

- **One-command install**: `setup-disk.sh` handles GPT partitioning, LUKS2 + LVM encryption, formatting, mounting and config deployment; `install.sh` initializes the host configuration [(scripts)](#scripts)
- **GPU auto-detection**: detects NVIDIA / AMD / Intel GPUs during installation and configures drivers and kernel parameters accordingly [(architecture)](docs/architecture.md)
- **Modular architecture**: clear directory layout with a strict system/user boundary, easy to extend and maintain [(architecture)](docs/architecture.md)
- **Multi-host support**: desktops, laptops and servers managed together, with modules assembled by host type [(architecture)](docs/architecture.md)
- **NixOS 26.05 compatible**: uses `kdePackages` for consistent KDE package versions and `hardware.graphics` (NixOS 24.11+) instead of `hardware.opengl`
- **Lix-powered Nix**: uses Lix instead of vanilla Nix for faster evaluation and fetching
- **Optimized boot**: systemd-boot + Plymouth quiet boot with reduced boot logs
- **Modular audio**: unified audio module (rtkit + PipeWire + PulseAudio compatibility layer)
- **China mirror acceleration**: USTC, Tsinghua and BFSU mirrors configured by default to speed up binary downloads

### Chinese & Office

- **Chinese input method**: Fcitx5 + RIME with the oh-my-rime framework (Mint Pinyin), supporting Pinyin, Shuangpin and Terra Pinyin schemes, plus a Catppuccin theme [(architecture)](docs/architecture.md)
- **Chinese fonts**: full coverage with Noto CJK, Source Han and WenQuanYi fonts [(architecture)](docs/architecture.md)
- **Spell checking**: system-level nuspell engine for English spell checking
- **WPS Office CN**: the Chinese edition of the office suite with better Chinese support
- **Nextcloud client**: cloud file synchronization support [(architecture)](docs/architecture.md)

### Terminal & Development

- **Default terminal foot**: lightweight high-performance terminal, with kitty and alacritty as alternatives [(architecture)](docs/architecture.md)
- **Modern CLI toolset**: eza, bat, fd, ripgrep, fzf, yazi (terminal file manager), zoxide (smart navigation), fastfetch, btop, dust, duf, tokei, hyperfine and procs replace classic tools
- **Polyglot development**: complete Go, Python, Rust and C/C++ environments with LSP support [(architecture)](docs/architecture.md)
- **Mouse side buttons**: back/forward bindings in Nemo, Firefox and other applications [(architecture)](docs/architecture.md)
- **Wallpaper repository**: full wallpaper collection at `https://github.com/hl4w/wallpaper.git`

## Requirements

| Item | Requirement |
|------|-------------|
| System | NixOS 26.05 installation media (ISO) recommended for fresh installs |
| Nix | Flakes enabled (`experimental-features = nix-command flakes`) |
| Privileges | `setup-disk.sh` requires root; `install.sh` needs permission to run `sudo nixos-generate-config` |
| Disk | The target disk is **completely wiped**; back up your data first |

## Quick Start

Pick the path that matches your situation: option 1 for a fresh machine, option 2 for an existing NixOS system, option 3 for full manual control.

### Option 1: Fresh install (boot from NixOS ISO)

```bash
# 1. Clone repository (Gitee mirror for China, GitHub elsewhere)
git clone https://gitee.com/hl4w/nixfiles.git
# git clone https://github.com/hl4w/nixfiles.git
cd nixfiles

# 2. Partition + encrypt + deploy config in one command (wipes the target disk)
#    <disk>      target disk device (e.g. /dev/nvme0n1, /dev/sda); partition names are derived
#    <hostname>  host name (also used as the flake configuration name)
#    <username>  user name
sudo ./scripts/setup-disk.sh <disk> <hostname> <username>

# Components are chosen interactively when omitted; they can also be passed explicitly
# sudo ./scripts/setup-disk.sh -T desktop -W hyprland -S dms <disk> <hostname> <username>

# To skip disk encryption (not recommended): add -c before the positional arguments
# sudo ./scripts/setup-disk.sh -c <disk> <hostname> <username>

# 3. Review the generated hardware configuration, then install
sudo nixos-install --flake .#<hostname>

# 4. Reboot into the new system
reboot
```

`setup-disk.sh` runs: GPT partition table → EFI partition → data partition (a LUKS2 container when encryption is enabled) → LVM (swap/root logical volumes) → formatting → mounting → repository clone → `install.sh` host generation. LVM is used with or without encryption: the disk has only an EFI and a data partition, `/` and swap are logical volumes, and `/home` lives under `/`; swap takes 10% of the disk capacity (clamped to 2–16 GiB).

`-T` (`desktop`/`laptop`/`server`), `-W` (`hyprland`/`niri`) and `-S` (`dms`/`noctalia`) select the components. When omitted, an interactive terminal prompts for them (Enter keeps the defaults `desktop`/`hyprland`/`dms`); with `-y` or non-TTY stdin the defaults are used and automation never blocks; choosing `server` skips the window manager and desktop shell prompts. Invalid values fail fast.

### Option 2: Existing NixOS system, host configuration only

```bash
git clone https://gitee.com/hl4w/nixfiles.git
cd nixfiles

chmod +x scripts/install.sh
./scripts/install.sh
```

Interactive mode asks for username, hostname, host type, window manager, desktop shell and polkit agent; values can also be passed directly:

```bash
./scripts/install.sh -y -U myuser -H my-hostname -T desktop -W hyprland -S dms -P kde
```

> `-y` runs non-interactively: missing required arguments cause an immediate error instead of a hanging prompt.

### Option 3: Manual deployment

```bash
# 1. Clone repository
git clone https://gitee.com/hl4w/nixfiles.git
cd nixfiles

# 2. Generate flake.lock (pins dependencies, includes the oh-my-rime input)
nix flake update

# 3. Copy the host template
cp -r templates/host-template hosts/<hostname>

# 4. Generate the hardware configuration (add --root /mnt when the target root is mounted there)
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix

# 5. Add the host entry to nixosConfigurations in flake.nix
#    my-hostname = mkHost "my-hostname";

# 6. Create the Home Manager user configuration
touch home/hosts/<hostname>.nix

# 7. Test build, deploy the system, update the user profile
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
sudo nixos-rebuild switch --flake .#<hostname>
home-manager switch --flake .#<username>@<hostname>
```

[(Detailed installation guide)](docs/migration_en.md)

### Pre-deployment verification

```bash
# Evaluation check (no compilation)
nix flake check

# Test build (no deployment)
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

> This repository exposes hosts via `nixosConfigurations`, so always use the full attribute path; `nix build .#<hostname>` only works when the flake additionally exposes `packages.<system>.<hostname>`.

## Project Structure

```
.
├── hosts/                    # Host configurations (system level, native NixOS options)
│   ├── common/               # Shared system config (default / desktop-common / hardware-common)
│   ├── desktop/              # Desktop host configuration
│   ├── laptop/               # Laptop host configuration
│   └── server/               # Server host configuration
├── modules/                  # System modules
│   ├── boot/                 # Boot configuration (systemd-boot, Plymouth)
│   ├── desktops/             # Desktop environments (hyprland, niri, sddm, shell-dms, shell-noctalia, unified-theme)
│   ├── hardware/             # Hardware config (nvidia, sound, bluetooth, firmware, mouse)
│   ├── input-method/         # Input method (Fcitx5 + RIME + oh-my-rime + Catppuccin theme)
│   ├── services/             # Services (network, security, virtualisation)
│   └── system/               # System basics (fonts, Lix, ...)
├── home/                     # Home Manager user config (user level, Home Manager-only options)
│   ├── common/               # Shared user modules (apps, cli, dev-lsp, editor, git, shell,
│   │                         #   input, hyprland, niri, unified-theme, wallpaper-watcher)
│   └── hosts/                # Host-specific user config (desktop / laptop / server)
├── scripts/                  # Install and maintenance scripts (Chinese and English variants)
├── templates/                # Template files
│   └── host-template/        # Host configuration template
├── wallpapers/               # Wallpapers
├── docs/                     # Documentation
├── secrets/                  # Sensitive configuration (not tracked)
├── .github/                  # CI workflows
└── flake.nix                 # Entry point (run nix flake update first to generate flake.lock)
```

### Configuration Layers

| Directory | Level | Description |
|-----------|-------|-------------|
| `hosts/` | System | NixOS system configuration, managed by root, native NixOS options only |
| `modules/` | System | Reusable NixOS modules imported by multiple hosts |
| `home/` | User | Home Manager user configuration, managed by a regular user, Home Manager-only options |

> The two layers stay strictly separated: Home Manager options such as `gtk.*`, `xdg.*` and `wayland.windowManager.*` must not appear under `modules/`; conversely, system options such as `environment.systemPackages` and `services.*` must not be written into `home/`.

## Scripts

Every script ships in two variants (`*.sh` in Chinese, `*_en.sh` in English).

| Script | Purpose | Common options |
|--------|---------|----------------|
| `setup-disk.sh <disk> <host> <user>` | Fresh install: partitioning, LUKS2 + LVM encryption, format/mount, config deployment | `-y` non-interactive, `-c` disable encryption, `-r` repository URL, `-T/-W/-S` host type / window manager / desktop shell (interactive when omitted) |
| `install.sh` | Initialize host config: generate `hosts/<host>`, `home/hosts/<host>.nix` and the hardware config, replace placeholders | `-y` non-interactive, `-U` username, `-H` hostname, `-G/-E` Git user/email, `-T/-W/-S/-P` component selection, `-N` flake configuration name |
| `update.sh` | Update flake inputs and rebuild the system | `-H` hostname (auto-detected by default) |
| `clean.sh` | Clean the Nix store and old generations | `-s` store only, `-g` generations only, `-a` all (default), `-y` auto-confirm |
| `setup-direnv.sh` | Configure direnv automatic environment loading | `-y` non-interactive |
| `wallpaper-color.sh` | Wallpaper color extraction and palette application | `-w` explicit wallpaper, `-s` set by name, `-d` random, `-l` list, `-c` current palette, `-a` apply palette only |
| `wallpaper-watcher.sh` | Watch wallpaper changes and refresh colors (invoked by a systemd user service) | `WATCH_INTERVAL` environment variable for the polling interval (seconds, default 5) |

> All scripts use `set -euo pipefail` with explicit argument validation; `setup-disk.sh` verifies root privileges and block-device existence before any destructive operation.

## Daily Operations

```bash
# Apply system module (modules/) changes
sudo nixos-rebuild switch --flake .#<hostname>

# Apply user configuration (home/) changes
home-manager switch --flake .#<username>@<hostname>

# Update all flake inputs (nixpkgs, home-manager, oh-my-rime, ...)
nix flake update

# One-click update (flake update + system rebuild)
./scripts/update.sh

# Clean old generations and the Nix store
./scripts/clean.sh

# Evaluation check and test build
nix flake check
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

## Documentation

Full documentation lives in `docs/`:

| Document | Description |
|----------|-------------|
| `docs/architecture.md` / `docs/architecture_en.md` | Architecture, module layout, configuration flow and CI |
| `docs/migration.md` / `docs/migration_en.md` | Migration and installation guide |
| `docs/faq.md` / `docs/faq_en.md` | Common questions and troubleshooting |
| `docs/shortcuts.md` / `docs/shortcuts_en.md` | Shortcut reference (Hyprland / Niri) |
| `docs/glossary.md` / `docs/glossary_en.md` | Terminology glossary and style rules |
| `docs/CHANGELOG.md` / `docs/CHANGELOG_EN.md` | Changelog |

## FAQ

See the [(FAQ)](docs/faq_en.md) first.

## License

GNU General Public License v3.0
