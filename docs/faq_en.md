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

- **DMS Shell**: Lightweight desktop shell (module: `programs.dms-shell`, configured in `shell-dms.nix`)
- **Noctalia Shell**: Modern desktop integration shell (configured in `shell-noctalia.nix`)

Both are Wayland shells. Select one in the host configuration via `desktop.shell`:

```nix
desktop.shell = "dms";     // or "noctalia"
```

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

### How do I regenerate flake.lock?

`flake.lock` locks all input versions (nixpkgs, home-manager, oh-my-rime, etc.). Regenerate it when:

- You first clone the repo (the repo does not commit `flake.lock`)
- You modify the `inputs` list in `flake.nix`
- You want to update an input to its latest version

```bash
# Update everything
nix flake update

# Update a specific input only
nix flake update nixpkgs
nix flake update home-manager

# Validate afterwards
nix flake check --no-build
```

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

### How do I add custom fonts?

Fonts are managed system-wide in `modules/system/fonts.nix`:

```nix
fonts.packages = with pkgs; [
  noto-fonts-cjk-sans
  noto-fonts-cjk-serif
  noto-fonts-color-emoji
  source-han-sans-sc
  source-han-serif-sc
  wqy_microhei
  wqy_zenhei
  nerd-fonts.jetbrains-mono
  # Add your fonts here:
  # fira-code
  # material-design-icons
];

# FontConfig fallback order
fonts.fontconfig.defaultFonts = {
  monospace = [ "JetBrainsMono Nerd Font" ];
  sans-serif = [ "Noto Sans CJK SC" ];
  serif = [ "Noto Serif CJK SC" ];
};
```

Apply with `sudo nixos-rebuild switch --flake .#<hostname>`.

### CLI Tools Quick Reference

This project ships with a curated set of modern CLI tools (all configured via `home/common/cli.nix`):

| Tool | Purpose | Common Usage |
|------|---------|-------------|
| `eza` | ls replacement | `eza -la`, `eza --tree=2` |
| `bat` | cat with syntax highlighting | `bat file.md`, `bat --paging=never` |
| `fd` | Fast file finder | `fd pattern`, `fd -e rs` |
| `rg` | Fast text search | `rg keyword`, `rg -t python` |
| `fzf` | Fuzzy search | `fzf` (Ctrl+R history, Ctrl+T files) |
| `yazi` | Terminal file manager | `yazi` (Ctrl+G opens shell + zoxide) |
| `zoxide` | Smart directory navigation | `z keyword`, `zi` (interactive), `z -` (previous) |
| `dust` | Disk usage analysis | `dust`, `dust -X` (sort by size) |
| `duf` | Disk space viewer | `duf`, `duf /dev/nvme0n1` |
| `tokei` | Code statistics | `tokei`, `tokei --types Rust,Go` |
| `hyperfine` | Command benchmarking | `hyperfine "ls" "eza"`, `hyperfine --runs 10 cmd` |
| `procs` | Enhanced ps | `procs`, `procs --tree`, `procs firefox` |
| `starship` | Cross-shell prompt | Auto-loaded, config in `~/.config/starship.toml` |

### What is Lix?

Lix is a high-performance alternative implementation of the Nix package manager:

- **Advantages**: Faster than native Nix (performance improvement up to 2-3x for eval and fetch operations)
- **Compatibility**: Fully compatible with all Nix features (flakes, nix-command, nix-shell, etc.)
- **Configuration**: Auto-configured via overlay in `modules/system/default.nix`

Verify installation:
```bash
nix --version
# Output: nix (Lix, like Nix) 2.x.x
```

### How do I configure Hyprland / Niri?

**Hyprland**: System-level enablement lives in `modules/desktops/hyprland.nix`; keybindings, window rules, gaps, animations and other details live in `home/common/hyprland.nix` using hyprlang syntax (`configType = "hyprlang"`).

**Niri**: System-level enablement lives in `modules/desktops/niri.nix`; keybindings and other details live in `home/common/niri.nix`.

The complete shortcut list is in `docs/shortcuts.md`.

### How do I configure DMS Shell / Noctalia Shell?

Both are enabled via official NixOS modules:

**DMS Shell**: `modules/desktops/shell-dms.nix` uses `programs.dms-shell.enable = true`. The module ships its dependencies and the `dms.service` systemd user unit; no manual service or dependency declarations are needed.

**Noctalia Shell**: `modules/desktops/shell-noctalia.nix` uses `programs.noctalia-shell.enable = true`. Ensure `services.upower.enable = true` (required by Noctalia v4).

Select which shell to use in the host configuration:

```nix
// hosts/<hostname>/configuration.nix
desktop.shell = "dms";       // or "noctalia"
```

### How do I configure input method (Chinese)?

The configuration uses Fcitx5 + RIME with oh-my-rime (Mint Pinyin) preset:
- System level: `modules/input-method/default.nix` (Fcitx5 engine, RIME addon, Catppuccin theme package)
- User level: `home/common/input.nix` (oh-my-rime framework deployment, schema list, theme settings)

**oh-my-rime configuration mechanism**:
- oh-my-rime is fetched as a flake input, defaulting to the CNB official mirror `git+https://cnb.cool/Mintimate/rime/oh-my-rime` (reliably reachable from mainland China); to go back to the GitHub upstream, enable the commented `github:Mintimate/oh-my-rime/main` under `inputs.oh-my-rime` in `flake.nix` (and comment out the mirror URL), then run `nix flake update oh-my-rime`
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

Colors are extracted from the wallpaper and applied to terminals (alacritty, kitty, foot), Starship prompt, Neovim and the DMS Shell / Noctalia Shell color config files.

**Auto Watcher**: The `wallpaper-watcher` systemd user service monitors wallpaper changes in `~/.wallpapers`. Status: `systemctl --user status wallpaper-watcher`.

### Wallpaper colors not applying?

Checklist:
- `pywal` is installed (declared in `modules/desktops/unified-theme.nix`)
- Wallpaper directory exists: `~/.wallpapers` (auto-created on first login)
- Colors are loaded in shell: `source ~/.cache/wal/colors.sh`
- Watcher service is running: `systemctl --user status wallpaper-watcher`
- Manual regeneration: run `wal -R`

### How do I use the day/night theme switching?

The unified theme supports automatic day/night switching:

```bash
# Auto-switch based on time (light: 6:00-18:00, dark: other times)
theme-auto

# Manually switch to dark theme
theme-dark

# Manually switch to light theme
theme-light
```

**Switching time configuration** (`hosts/<hostname>/configuration.nix`):

```nix
desktop.unified-theme = {
  themeMode = "auto";    // dark / light / auto
  dayStart = 6;          // Day start hour
  nightStart = 18;       // Night start hour
};
```

### How do I configure Chinese mirrors?

Mirrors are configured in both `flake.nix` (nixConfig) and `modules/system/default.nix` (nix.settings):

```nix
substituters = [
  "https://mirrors.ustc.edu.cn/nix-channels/store"  // USTC (recommended)
  "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"  // Tsinghua
  "https://mirrors.bfsu.edu.cn/nix-channels/store"  // BFSU
  "https://cache.nixos.org"  // Official (fallback)
];
```

## Troubleshooting

### Message: experimental Nix feature 'nix-command' is disabled

The current environment (installer ISO or an older system without flakes) has not enabled the experimental features. Three ways to handle it:

```bash
# 1. Enable per command (works for any nix command)
nix --extra-experimental-features "nix-command flakes" flake lock

# 2. Enable for the current session (also applies to nixos-install)
export NIX_CONFIG='experimental-features = nix-command flakes'
sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-install --flake .#<hostname>

# 3. Enable system-wide after installation (in configuration.nix)
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

The repo's `scripts/install.sh` and `scripts/update.sh` already pass this flag internally, and `modules/system/default.nix` enables flakes for the installed system.

### Flake build fails

Identify the problem with:

```bash
# Quick evaluation only (no compile)
nix flake check --no-build

# Full error trace
nix flake check --no-build 2>&1 | tail -50

# Test a single host build
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

### Home Manager switch fails

```bash
# Detailed output
home-manager switch --flake .#user@host 2>&1 | tail -30

# Verbose mode
home-manager switch --flake .#user@host --verbose
```

### Hyprland won't start

Ensure:
- Graphics drivers are properly installed
- `xdg-desktop-portal-hyprland` is in system packages
- SDDM is running in Wayland mode
- Check logs in `~/.local/share/hyprland/`
- Validate config syntax (Hyprland 0.55+): `hyprctl config -h`

### Niri won't start

Ensure:
- Wayland session is properly configured
- SDDM is using the correct session file
- `xdg-desktop-portal-niri` is installed

### No sound

Check:
- PipeWire status: `systemctl --user status pipewire pipewire-pulse`
- Correct audio device selected: `wpctl status`
- User is in the `audio` group: `id | grep -o 'audio'`

### SDDM won't start

Check:
- Display manager is enabled: `services.displayManager.sddm.enable = true`
- Wayland mode is enabled: `services.displayManager.sddm.wayland.enable = true`
- Graphics drivers are properly configured
- `qt6Packages.qtwayland` is installed

### kdePackages/qt6Packages package not found

In NixOS 26.05, some Qt packages require specific prefixes:

```nix
// Correct
qt6Packages.qtwayland
kdePackages.polkit-kde-agent-1
qt6Packages.fcitx5-configtool
qt6Packages.fcitx5-chinese-addons

// Wrong
qtwayland
polkit-kde-agent
fcitx5-configtool
fcitx5-chinese-addons
```

### Fcitx5 won't switch to Chinese input

```bash
# 1. Verify fcitx5 is running
fcitx5 -d

# 2. List RIME schemes
rime_dict_manager list-schemas
fcitx5-diagnose

# 3. Check environment variables (SDDM launcher should set them)
echo $GTK_IM_MODULE   // should be fcitx
echo $QT_IM_MODULE    // should be fcitx
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
- Set `nix.settings.max-jobs` based on CPU cores
- Enable `nix.settings.auto-optimise-store = true`

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

```bash
# Update system config (after modifying modules/)
sudo nixos-rebuild switch --flake .#<hostname>

# Update Home Manager user config (after modifying home/)
home-manager switch --flake .#<username>@<hostname>

# Update flake inputs (upgrade nixpkgs and other deps)
nix flake update

# Or use the update script (one-click flake update + system rebuild)
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
# Fast syntax check (no compile)
nix flake check --no-build

# Full test build (no deploy)
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Preview what would change
nixos-rebuild dry-activate --flake .#<hostname>
```

### How do I rollback after update?

```bash
# List system generations
sudo nixos-rebuild list-generations

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Rollback to a specific generation
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
