# NixOS Configuration

**Version: v0.0.3**

**HL4W** - Modern NixOS 26.05 configuration repository using Nix Flakes + Home Manager to manage system and user environments across multiple machines.

## Features

- **Hyprland** / **Niri**: Wayland window managers [(Details)](docs/architecture.md)
- **Modular Architecture**: Clear directory structure for easy extension and maintenance [(Architecture)](docs/architecture.md)
- **Multi-host Support**: Unified management for desktop, laptop, and server [(Architecture)](docs/architecture.md)
- **GPU Auto-Detection**: Automatically identifies NVIDIA/AMD/Intel GPUs during installation, intelligently configures drivers and kernel parameters [(Architecture)](docs/architecture.md)
- **Unified Theming**: Consistent GTK/Qt/Hyprland/Niri/Shell/SDDM color schemes [(Architecture)](docs/architecture.md)
- **Wallpaper Auto-color**: Uses pywal to extract colors from wallpaper [(Architecture)](docs/architecture.md)
- **Day/Night Theme Switching**: Automatic light/dark theme switching based on time [(Architecture)](docs/architecture.md)
- **WPS Office CN**: Chinese version office suite with better Chinese support [(Architecture)](docs/architecture.md)
- **Chinese Fonts**: Full support for Noto CJK, Source Han, WenQuanYi fonts [(Architecture)](docs/architecture.md)
- **Default Terminal**: foot (lightweight high-performance terminal), with kitty and alacritty also supported [(Architecture)](docs/architecture.md)
- **Nextcloud Client**: Cloud file sync support [(Architecture)](docs/architecture.md)
- **Mouse Side Buttons**: Back/forward navigation in Nemo, Firefox and other applications [(Architecture)](docs/architecture.md)
- **Flexible Desktop Configuration**: Dynamic window manager (Hyprland/Niri) and desktop shell (DMS/Noctalia) selection [(Architecture)](docs/architecture.md)
- **Multi-language Development Support**: Complete development environment for Go, Python, Rust, and C/C++ with LSP support [(Architecture)](docs/architecture.md)
- **NixOS 26.05 Compatibility**: Uses kdePackages for KDE package version compatibility, hardware.graphics (NixOS 24.11+) replaces hardware.opengl
- **Modern CLI Toolset**: eza, bat, fd, rg, fzf, yazi (terminal file manager), zoxide (smart navigation), fastfetch, btop, dust, duf, tokei, hyperfine, procs replacing traditional tools
- **Optimized Boot Configuration**: systemd-boot + Plymouth quiet boot with reduced logging
- **Lix High-Performance Nix**: Uses Lix instead of native Nix for better performance
- **Modular Audio Configuration**: Unified audio module (rtkit + PipeWire + PulseAudio compatibility)
- **Spell Checker Support**: System-level nuspell engine with English dictionary support
- **Chinese Mirror Acceleration**: Pre-configured with USTC, Tsinghua, BFSU mirrors for faster binary downloads
- **Wallpaper Repository**: Full wallpaper collection available at `https://github.com/hl4w/wallpaper.git`

## Quick Start

### Using Installation Script (Recommended)

```bash
# Clone repository
git clone <repo-url>
cd nixfiles26

# Run installation script
chmod +x scripts/install.sh
./scripts/install.sh
```

### Manual Deployment

```bash
# 1. Clone repository
git clone <repo-url>
cd nixfiles26

# 2. Create host configuration directory (copy template)
cp -r templates/host-template hosts/<hostname>

# 3. Generate hardware configuration
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix

# 4. Edit flake.nix, add host entry in nixosConfigurations
# my-hostname = mkHost "my-hostname";

# 5. Create Home Manager user configuration
touch home/hosts/<hostname>.nix

# 6. Build configuration
nix build .#<hostname>

# 7. Deploy system
sudo nixos-rebuild switch --flake .#<hostname>

# 8. Update user configuration
home-manager switch --flake .#<username>@<hostname>
```

[(Detailed Installation Guide)](docs/migration.md)

## Documentation

See `docs/` directory for detailed documentation:

| Document | Description |
|----------|-------------|
| `docs/changelog.md` | Changelog |
| `docs/changelog_en.md` | Changelog (English) |
| `docs/architecture.md` | Architecture overview, module structure, configuration flow |
| `docs/architecture_en.md` | Architecture overview (English) |
| `docs/faq.md` | Frequently asked questions and troubleshooting |
| `docs/faq_en.md` | Frequently asked questions (English) |
| `docs/migration.md` | Migration guide |
| `docs/migration_en.md` | Migration guide (English) |

## Project Structure

```
.
├── hosts/                    # Host configurations (system-level)
│   ├── common/               # Common host configurations
│   ├── desktop/              # Desktop host configuration (configuration.nix)
│   ├── laptop/               # Laptop host configuration (configuration.nix)
│   └── server/               # Server host configuration (configuration.nix)
├── modules/                  # System modules
│   ├── boot/                 # Boot-related configurations
│   ├── desktops/             # Desktop environment configs (Hyprland, Niri, themes)
│   ├── hardware/             # Hardware configurations
│   ├── input-method/         # Input method configuration (Fcitx5 + RIME)
│   ├── services/             # Service configurations (network, security, virtualization)
│   └── system/               # System base configurations (fonts, users, env vars)
├── home/                     # Home Manager user configurations (user-level)
│   ├── common/               # Common user configurations (apps, Shell, terminal)
│   └── hosts/                # Host-specific user configurations
│       ├── desktop/          # Desktop-specific packages
│       ├── laptop/           # Laptop-specific packages
│       └── server/           # Server-specific configuration
├── scripts/                  # Helper scripts
├── templates/                # Template files
│   └── host-template/        # Host configuration template
├── wallpapers/               # Wallpaper files
├── docs/                     # Documentation
├── secrets/                  # Sensitive configurations (not version controlled)
├── flake.nix                 # Entry point configuration
└── flake.lock                # Version lockfile
```

### Configuration Layers

| Directory | Level | Description |
|-----------|-------|-------------|
| `/hosts/` | System-level | NixOS system configuration, managed by root |
| `/home/` | User-level | Home Manager user configuration, managed by regular users |

## Management Commands

```bash
# Update flake
nix flake update

# Update system
./scripts/update.sh

# Clean old generations
./scripts/clean.sh

# Check configuration
nix flake check
```

[(Script Usage Documentation)](docs/architecture.md)

## FAQ

Having issues? Check [(FAQ)](docs/faq.md)

## License

GNU General Public License v3.0