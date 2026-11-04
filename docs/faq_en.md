# HL4W FAQ

## General

### What is this configuration?

HL4W is a NixOS 26.05 configuration repository that uses Nix Flakes and Home Manager to manage system and user configurations across multiple machines. It supports Hyprland and Niri window managers, using Wayland only.

### Why use Flakes?

Flakes provide reproducible builds, better dependency management, and a cleaner way to structure Nix configurations.

### What window managers are supported?

- **Hyprland**: Dynamic tiling window manager with hyprlang configuration (`configType = "hyprlang"`)
- **Niri**: Modern scrollable-tiling window manager, recommended for laptops

### What desktop shells are available?

- **DMS Shell**: Lightweight desktop shell
- **Noctalia Shell**: Modern desktop integration shell

## Installation

### How do I install NixOS with this configuration?

For a fresh machine (booted from the NixOS ISO), run the disk setup script. `setup-disk.sh` clones the repository to `/mnt/etc/nixos` after mounting the target disk, then invokes `install.sh` with `-y` to generate the host configuration, `nix flake lock` to pin dependencies, and `nixos-generate-config --root /mnt` to write the hardware configuration. Review the generated files and run `nixos-install`:

```bash
# If you already cloned the repo, just run it directly (it clones again to /mnt/etc/nixos anyway)
sudo ./scripts/setup-disk.sh <disk> <hostname> <username>

# When the script finishes, cd to /mnt/etc/nixos and install
cd /mnt/etc/nixos
sudo nixos-install --flake .#<hostname>
```

If `-T/-W/-S` are omitted, the script prompts in an interactive terminal for host type, window manager and desktop shell (Enter keeps the defaults `desktop`/`hyprland`/`dms`); with `-y` or non-TTY stdin it uses the defaults without blocking.

On an existing NixOS system, use `install.sh` to generate the host configuration:

**Method 1: Using install.sh (Recommended)**

```bash
# Clone repository
# Chinese users recommended to use Gitee mirror:
git clone https://gitee.com/hl4w/nixfiles.git
# International users use GitHub:
# git clone https://github.com/hl4w/nixfiles.git
cd nixfiles

# Generate flake.lock before the first run (includes the oh-my-rime input)
nix flake update

# Run installation script (prompts interactively for each configuration item)
chmod +x scripts/install.sh
./scripts/install.sh
```

The script will guide you through:
1. Enter username, hostname, Git info
2. Select host type (Desktop/Laptop/Server)
3. Select window manager (Hyprland/Niri)
4. Select desktop shell (DMS Shell / Noctalia Shell)
5. Select polkit agent (KDE/Hyprland)
6. Generate hardware config and deploy

For non-interactive mode pass flags directly, e.g. `./scripts/install.sh -y -U john -H my-desktop -T desktop -W hyprland -S dms -P kde` (`-y` auto-confirms prompts and `-N` sets the flake configuration name; run `./scripts/install.sh -h` for all options).

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
| Desktop packages | `home/common/apps.nix` | rofi, nemo, nemo-extensions, evince, loupe, alacritty/kitty/foot (foot default), vlc |
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

System-level enablement lives in `modules/desktops/hyprland.nix`; keybindings, window rules and other details live in `home/common/hyprland.nix` using hyprlang syntax (`configType = "hyprlang"`).

### How do I configure Niri?

System-level enablement lives in `modules/desktops/niri.nix`; keybindings and other details live in `home/common/niri.nix`.

### How do I configure input method (Chinese)?

The configuration uses Fcitx5 + RIME with oh-my-rime (Mint Pinyin) preset:
- System level: `modules/input-method/default.nix` (Fcitx5 engine, RIME addon, Catppuccin theme package)
- User level: `home/common/input.nix` (oh-my-rime framework deployment, schema list, theme settings)

**oh-my-rime configuration mechanism**:
- oh-my-rime is fetched as a flake input (`github:Mintimate/oh-my-rime/main`)
- schema/dict/lua files are symlinked to `~/.local/share/fcitx5/rime/` via `home.file`
- `default.custom.yaml` overrides `schema_list` to specify enabled schemes (default: rime_mint, rime_mint_flypy, terra_pinyin, stroke)

**Catppuccin theme switching**:
Modify the `Theme` value in `classicui.conf` within `home/common/input.nix`, format: `catppuccin-{flavor}-{accent}`:
- flavor: `latte` (light), `frappe`, `macchiato`, `mocha` (dark)
- accent: `rosewater`, `flamingo`, `pink`, `mauve`, `red`, `maroon`, `peach`, `yellow`, `green`, `teal`, `sky`, `sapphire`, `blue`, `lavender`
- Restart fcitx5 with `fcitx5 -r` to apply changes

### How do I use the wallpaper auto-color feature?

This configuration includes a wallpaper auto-color system using `pywal`:

```bash
# Set specified wallpaper and apply colors (-s requires a name or path)
wp-color -s my-wallpaper.png

# Pick a random wallpaper from ~/.wallpapers (same as wp-color -d)
wp-random

# Apply the current color scheme only (no wallpaper change, no re-extraction)
wp-color -a

# List available wallpapers / show current colors
wp-color -l
wp-color -c
```

Colors are automatically extracted from the wallpaper and applied to:
- Terminal (alacritty, kitty, foot)
- Shell prompt (Starship)
- Neovim/Emacs editors
- DMS Shell and Noctalia Shell

**Auto Watcher**: The system automatically monitors wallpaper changes. When you select a wallpaper via DMS Shell / Noctalia Shell GUI, colors will be updated automatically.

### Wallpaper colors not applying?

Ensure:
- `pywal` is installed (declared in `modules/desktops/unified-theme.nix`)
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
- Both `modules/desktops/unified-theme.nix` (system) and `home/common/unified-theme.nix` (user) are imported
- Commands are available: `which theme-auto theme-dark theme-light`
- Theme scripts are generated via `writeScriptBin` in `modules/desktops/unified-theme.nix` and added to `environment.systemPackages`

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
- Display manager is enabled: `services.displayManager.sddm.enable = true`
- Wayland mode is enabled: `services.displayManager.sddm.wayland.enable = true`
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

- Enable `powerManagement.cpuFreqGovernor = "performance"` for desktop
- Use `boot.kernelParams` for hardware-specific optimizations
- Add `nix.settings.max-jobs` based on CPU cores

### How do I optimize Nix build speed?

- Use Chinese mirrors for faster binary downloads
- Enable `nix.settings.auto-optimise-store = true`
- Increase `nix.settings.max-jobs` for parallel builds

## Security

### How do I manage secrets?

The `secrets/` directory is reserved for encrypted secrets, but the default configuration does not yet integrate the agenix module. To use it, follow `secrets/README.md` to add agenix to the flake inputs and host configuration.

### How do I enable the firewall?

Firewall is enabled by default in `modules/services/security.nix`. Add allowed ports as needed.

### How do I configure UEFI boot?

UEFI boot with systemd-boot is configured in `modules/boot/default.nix`:
- Keeps 3 boot entries by default
- Uses systemd-boot instead of GRUB

## Updates

### How do I update the system?

After installation, if you modify any Nix modules, you can directly update the system using the following commands:

```bash
# Update system (use after modifying modules/)
sudo nixos-rebuild switch --flake .#<hostname>

# Update Home Manager user configuration (use after modifying home/)
home-manager switch --flake .#<username>@<hostname>

# Update flake inputs (upgrade dependency versions like nixpkgs)
nix flake update

# Or use the update script (one-click flake update and system rebuild)
./scripts/update.sh
```

### How do I apply changes after modifying modules?

**Modify system modules** (`modules/` directory):
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

**Modify user configuration** (`home/` directory):
```bash
home-manager switch --flake .#<username>@<hostname>
```

**Update both system and user configuration**:
```bash
./scripts/update.sh
```

### How do I verify configuration before deployment?

```bash
# Check configuration syntax (fast)
nix flake check

# Test build (no deployment)
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Preview changes
nixos-rebuild dry-activate --flake .#<hostname>
```

### How do I rollback after update?

```bash
# List system generations
sudo nixos-rebuild list-generations

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or rollback to specific generation
sudo nixos-rebuild switch --generation <number>

# Home Manager rollback
home-manager rollback
```

### How do I clean old generations?

```bash
# Clean user generations
nix-collect-garbage -d

# Clean system generations
sudo nix-collect-garbage -d

# Or use the cleanup script (-a all, -s store only, -g old generations only)
./scripts/clean.sh -a
```