


# Silas's Nix Configuration

This repository contains the NixOS and Home Manager configuration files that build and manage my personal systems. It uses Nix flakes for declarative, reproducible system deployments.

## Why Nix?

Nix is a powerful package manager and configuration management tool that enables:
- **Reproducible deployments**: Once configured, the system works exactly the same every time
- **Collaborative configurations**: Share your setup with others, and they can deploy identical environments
- **Easy rollbacks**: Previous system states can be recovered instantly
- **Declarative management**: Define what you want, and Nix figures out how to achieve it

## Project Structure

```
nixfiles/
├── flake.nix              # Main flake input and outputs
├── flake.lock             # Locked dependencies
├── home/                  # Home Manager configurations
│   ├── bashrc             # Bash shell configuration
│   ├── core.nix           # Core home manager settings
│   ├── dunst/             # Notification daemon
│   ├── fastfetch/          # System info display tool
│   ├── fcitx5/            # Chinese input method (Rime)
│   ├── hypr/              # Hyprland (Wayland compositor)
│   ├── nvim/              # Neovim editor
│   ├── programs/          # Various program configurations
│   ├── rofi/              # Application launcher
│   ├── scripts/           # User scripts
│   ├── settings/         # System settings
│   ├── shell/            # Shell configuration
│   ├── starship/         # Prompt configuration
│   ├── swappy/           # Screenshot tool
│   ├── wal/              # Wallpaper and colors
│   ├── wallpapers/       # Wallpaper images
│   ├── waybar/           # Status bar
│   └── wlogout/          # Logout screen
├── hosts/                 # Host-specific configurations
│   ├── default.nix
│   └── hardware-configuration.nix
├── modules/               # NixOS modules
│   ├── ai-robot.nix
│   ├── auto-upgrade.nix
│   ├── bootloader.nix
│   ├── chinese.nix
│   ├── dns.nix
│   ├── flatpak-module.nix
│   ├── gc.nix
│   ├── hardware.nix
│   ├── hyprland.nix
│   ├── linux-kernel.nix
│   ├── noctalia.nix
│   └── virtualization.nix
├── users/                 # User configurations
│   ├── home.nix
│   └── nixos.nix
├── install.sh             # Installation script
└── setup.sh               # Setup script
```

## Key Components

### Desktop Environment
- **Hyprland**: Wayland compositor with extensive customization
- **Waybar**: Highly customizable status bar
- **Rofi**: Application launcher and dmenu replacement
- **Dunst**: Notification daemon

### Input Methods
- **Fcitx5 Rime**: Chinese input method with flypy schema

### Utilities
- **Fastfetch**: System information display
- **Swappy**: Screenshot annotation
- **Wallpaper Engine**: Dynamic wallpapers

### Scripts
- System management scripts (reboot, shutdown, suspend, lock)
- Wallpaper management
- Screenshot capture
- Theme switching

## Installation

### Prerequisites

1. Install NixOS with the following options enabled:
   - `nix-command`
   - `flakes`

### Deploying the Configuration

After installing NixOS, deploy this flake with:

```bash
sudo nixos-rebuild switch --flake .#nixos-test
```

Replace `nixos-test` with the appropriate hostname from the flake outputs.

### Fresh Installation

For a fresh system installation, use the provided install script:

```bash
./install.sh
```

## Usage

### Rebuilding

After modifying any configuration files, rebuild the system:

```bash
sudo nixos-rebuild switch --flake .#
```

### Updating

Update all flake inputs:

```bash
sudo nixos-rebuild switch --flake .# --update
```

Or use the auto-upgrade module for automatic updates.

## Customization

### Waybar Themes

Multiple Waybar themes are available in `home/waybar/themes/`:
- hl4w (default)
- hl4w-blur
- hl4w-blur-bottom
- hl4w-minimal
- starter

Switch themes using the theme switcher script.

### Hyprland Configuration

Hyprland settings are highly customizable through configuration files in `home/hypr/conf/`:
- Animations
- Decorations
- Keybindings
- Monitor setups
- Window rules

### Scripts

Various utility scripts are available in `home/scripts/` and `home/hypr/scripts/` for:
- Application launching
- System control
- Wallpaper management
- And more

## License

This configuration is provided as-is for personal use. Feel free to study and adapt the configurations for your own NixOS setups.