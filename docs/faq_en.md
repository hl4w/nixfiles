# HL4W FAQ

## General

### What is this configuration?

HL4W is a NixOS 26.05 configuration repository that uses Nix Flakes and Home Manager to manage system and user configurations across multiple machines. It supports Hyprland and Niri window managers, using Wayland only.

### Why use Flakes?

Flakes provide reproducible builds, better dependency management, and a cleaner way to structure Nix configurations.

### What window managers are supported?

- **Hyprland**: Dynamic tiling window manager with Lua configuration (via hyprnix)
- **Niri**: Modern scrollable-tiling window manager, recommended for laptops

### What desktop shells are available?

- **DMS-Shell**: Lightweight display manager shell
- **Noctalia-Shell**: Modern desktop integration shell

## Installation

### How do I install NixOS with this configuration?

**Method 1: Using install.sh (Recommended)**

```bash
# Clone repository
git clone <repo-url>
cd nixfiles26

# Run installation script
chmod +x scripts/install.sh
./scripts/install.sh
```

The script will guide you through:
1. Enter username, hostname, Git info
2. Select host type (Desktop/Laptop/Server)
3. Select window manager (Hyprland/Niri)
4. Select desktop shell (DMS-Shell/Noctalia-Shell)
5. Generate hardware config and deploy

**Method 2: Manual Installation**

1. Boot from NixOS installer
2. Partition your disk
3. Mount partitions
4. Clone this repository
5. Generate hardware config: `nixos-generate-config --show-hardware-config > hosts/your-host/hardware-configuration.nix`
6. Run: `nixos-install --flake .#your-host`

### How do I add a new host?

See `docs/architecture.md` for detailed instructions, or simply run `./scripts/install.sh`.

## Configuration

### How do I customize my shell?

Edit `home/common/shell.nix` for shared shell configuration or create host-specific overrides in `home/hosts/`.

### How do I add packages?

| Package Type | Location | Example |
|--------------|----------|---------|
| System packages | `modules/system/default.nix` | git, wget, curl, tmux, zsh |
| User packages | `home/common/cli.nix` | fastfetch, btop, eza, bat, fzf, fd, ripgrep, yazi, zoxide, dust, duf, tokei, hyperfine, procs |
| Desktop packages | `home/common/apps.nix` | rofi, nemo, nemo-extensions, evince, eog, alacritty/kitty/foot (foot default), vlc |
| Development packages | `home/common/dev-lsp.nix` | clangd, clang-tools, cmake, ninja, gdb, lldb, go, gopls, python3, pyright, rustc, rust-analyzer, rustfmt, cargo |
| Office packages | `home/common/apps.nix` | wps-office-cn, nextcloud-client |

### How do I use Yazi file manager?

Yazi is a fast terminal file manager configured in `home/common/cli.nix`:

```bash
# Launch Yazi
yazi

# Basic operations
# Arrow keys / hjkl: Navigate
# Enter: Open file/directory
# q: Quit
# : Open command panel
# Ctrl+G: Open shell (supports zoxide jump)
```

### How do I use Zoxide smart navigation?

Zoxide is configured in `home/common/cli.nix`:

```bash
# Jump to directory containing keyword
z <keyword>

# Interactive selection
zi

# Jump to previous directory
z -

# Add directory to database
z ~/projects/my-project
```

### What is Lix?

Lix is a high-performance alternative implementation of the Nix package manager:

- **Advantages**: Faster than native Nix (performance improvement up to 2-3x for eval and fetch operations)
- **Compatibility**: Fully compatible with all Nix features (flakes, nix-command, nix-shell, etc.)
- **Performance**: Rewritten in C++ with better memory efficiency
- **Configuration**: Auto-configured via overlay in `modules/system/default.nix`

Verify installation:
```bash
nix --version
# Output: nix (Lix, like Nix) 2.x.x
```

### How do I use dust for disk usage analysis?

```bash
# Check current directory disk usage
dust

# Check specific directory
dust ~/projects

# Show file sizes
dust -s

# Sort by size
dust -X
```

### How do I use duf to view disk space?

```bash
# View all disks
duf

# View specific device
duf /dev/nvme0n1p2

# JSON output
duf --json
```

### How do I use tokei for code statistics?

```bash
# Count code in current directory
tokei

# Exclude directories
tokei --exclude "node_modules"

# JSON output
tokei --json

# Only count specific languages
tokei --types Rust,Go,Python
```

### How do I use hyperfine for command performance testing?

```bash
# Compare two commands
hyperfine "ls -la" "eza -la"

# Multiple runs
hyperfine --runs 10 "my-command"

# Warmup runs
hyperfine --warmup 3 "my-command"
```

### How do I use procs to view processes?

```bash
# View all processes
procs

# Search for process
procs firefox

# Tree view
procs --tree

# Detailed information
procs -l
```

### How do I configure Hyprland?

Edit `modules/desktops/hyprland.nix` for system-level configuration. Hyprland uses Lua syntax managed by hyprnix.

### How do I configure Niri?

Edit `modules/desktops/niri.nix` for system-level configuration.

### How do I configure input method (Chinese)?

The configuration uses Fcitx5 + RIME with oh-my-rime preset:
- System level: `modules/input-method/default.nix`
- User level: `home/common/input.nix`

### How do I use the wallpaper auto-color feature?

This configuration includes a wallpaper auto-color system using `pywal`:

```bash
# Set specified wallpaper and apply colors
wp-color -s my-wallpaper.png

# Use default wallpaper (default.jpg)
wp-color -s

# Randomly select wallpaper from ~/.wallpapers/
wp-random

# Apply current colors without changing wallpaper
wp-apply

# List available wallpapers
wp-list
```

Colors are automatically extracted from the wallpaper and applied to:
- Terminal (alacritty, kitty, foot)
- Shell prompt (Starship)
- Neovim/Emacs editors
- Noctalia-Shell and DMS-Shell

**Auto Watcher**: The system automatically monitors wallpaper changes. When you select a wallpaper via Noctalia-Shell/DMS-Shell GUI, colors will be updated automatically.

### Wallpaper colors not applying?

Ensure:
- `pywal` is installed (included in `unified-theme.nix`)
- Wallpaper directory exists: `~/.wallpapers` (automatically created)
- Colors are loaded in shell: `source ~/.cache/wal/colors.sh`
- Wallpaper watcher service is running: `systemctl --user status wallpaper-watcher`

### How do I use the day/night theme switching?

The unified theme supports automatic day/night theme switching:

```bash
# Auto-switch based on time (light: 6:00-18:00, dark: other times)
theme-auto

# Manually switch to dark theme
theme-dark

# Manually switch to light theme
theme-light
```

### How do I configure day/night theme switching?

Add the following to your host configuration (`hosts/<hostname>/configuration.nix`):

```nix
desktop.unified-theme = {
  themeMode = "auto";    # dark/light/auto
  dayStart = 6;          # Day start hour
  nightStart = 18;       # Night start hour
};
```

### Theme switching not working?

Ensure:
- `unified-theme.nix` is imported in your host configuration
- Commands are available: `which theme-auto theme-dark theme-light`
- Theme scripts are in `environment.systemPackages`

### How do I configure Chinese mirrors?

Mirrors are configured in both `flake.nix` (nixConfig) and `modules/system/default.nix` (nix.settings):

```nix
substituters = [
  "https://mirrors.ustc.edu.cn/nix-channels/store"  # USTC (recommended)
  "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"  # Tsinghua
  "https://mirrors.bfsu.edu.cn/nix-channels/store"  # BFSU
  "https://cache.nixos.org"  # Official (fallback)
];
```

## Troubleshooting

### Flake build fails

Check the error message for missing dependencies or syntax errors. Run `nix flake check` to validate the flake.

### Home Manager switch fails

Check `home-manager switch --flake .#user@host` output for detailed error messages.

### Hyprland won't start

Ensure:
- Graphics drivers are properly installed
- `xdg-desktop-portal-hyprland` is in `environment.systemPackages`
- SDDM is running in Wayland mode
- Logs are in `~/.local/share/hyprland/`

### Niri won't start

Ensure:
- Wayland session is properly configured
- SDDM is using the correct session file
- `xdg-desktop-portal-niri` is installed

### No sound

Check:
- PipeWire is enabled: `systemctl --user status pipewire`
- Correct audio device is selected
- User is in `audio` group

### SDDM won't start

Check:
- Display manager is enabled: `services.sddm.enable = true`
- Wayland mode is enabled: `services.sddm.wayland.enable = true`
- Graphics drivers are properly configured
- `qt6Packages.qtwayland` is installed

### kdePackages/qt6Packages package not found

In NixOS 26.05, some Qt packages require specific prefixes:

```nix
# Correct
qt6Packages.qtwayland
kdePackages.polkit-kde-agent-1
qt6Packages.fcitx5-configtool
qt6Packages.fcitx5-chinese-addons

# Wrong
qtwayland
polkit-kde-agent
fcitx5-configtool
fcitx5-chinese-addons
```

### Binary download is slow

Ensure Chinese mirrors are configured in `flake.nix` and `modules/system/default.nix`. Check with:

```bash
nix show-config | grep substituters
```

## Performance

### How do I optimize performance?

- Enable `services.powerManagement.cpuFreqGovernor = "performance"` for desktop
- Use `boot.kernelParams` for hardware-specific optimizations
- Add `nix.settings.max-jobs` based on CPU cores

### How do I optimize Nix build speed?

- Use Chinese mirrors for faster binary downloads
- Enable `nix.settings.auto-optimise-store = true`
- Increase `nix.settings.max-jobs` for parallel builds

## Security

### How do I manage secrets?

Use `agenix` to encrypt secrets. See `secrets/README.md` for details.

### How do I enable the firewall?

Firewall is enabled by default in `modules/services/security.nix`. Add allowed ports as needed.

### How do I configure UEFI boot?

UEFI boot with systemd-boot is configured in `modules/boot/default.nix`:
- Keeps 3 boot entries by default
- Uses systemd-boot instead of GRUB

## Updates

### How do I update the system?

```bash
# Update flake inputs
nix flake update

# Rebuild system
sudo nixos-rebuild switch --flake .#hostname

# Or use the update script
./scripts/update.sh
```

### How do I clean old generations?

```bash
# Clean user generations
nix-collect-garbage -d

# Clean system generations
sudo nix-collect-garbage -d

# Or use the clean script
./scripts/clean.sh
```