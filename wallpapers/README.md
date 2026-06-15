# Wallpapers

This directory contains wallpaper images for the NixOS configuration.

## Usage

1. Add your wallpaper images to this directory (supports: .jpg, .jpeg, .png, .gif)
2. During installation, wallpapers will be automatically copied to `~/.wallpapers/`
3. Use the following commands to manage wallpapers:

```bash
# Use default wallpaper (default.png)
wp-color -s

# Set specified wallpaper and apply colors
wp-color -s my-wallpaper.png

# Randomly select from wallpaper directory
wp-random

# Apply current colors (without changing wallpaper)
wp-apply

# List available wallpapers
wp-list
```

## Recommended Wallpaper Specifications

- Aspect ratio: 16:9 or 16:10
- Resolution: 1920x1080 or higher
- File format: PNG (lossless) or JPEG (compressed)

## Included Wallpapers

| File | Description |
|------|-------------|
| `default.jpg` | Default wallpaper (1920x1080) |
| `hyprland.jpg` | Hyprland themed wallpaper |
| `kath.jpg` | Abstract wallpaper |
| `nixos-2.jpeg` | NixOS themed wallpaper |
| `nixos-3.jpeg` | NixOS themed wallpaper |

## Default Wallpaper

The `default.png` file is used as the default wallpaper when no specific wallpaper is specified. It will be automatically applied during the first login.

**Style:** Chinese style / Dark theme
- Features traditional Chinese elements
- Deep, rich color palette
- Suitable for dark theme environments