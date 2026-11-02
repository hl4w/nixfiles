# Wallpapers

This directory contains wallpaper images for the NixOS configuration.

## Full Wallpaper Collection

For the complete wallpaper collection with more options, please clone the dedicated wallpaper repository:

```bash
git clone https://github.com/hl4w/wallpaper.git
```

After cloning, copy the desired wallpapers to this directory or symlink the repository to `~/.wallpapers/` for automatic integration with the pywal color system.

## Usage

1. Add your wallpaper images to this directory (supports: .jpg, .jpeg, .png, .gif, .webp)
2. During installation, wallpapers will be automatically copied to `~/.wallpapers/`
3. Use the following commands to manage wallpapers (`wp-color` and `wp-random` are shell aliases defined in `home/common/shell.nix`):

```bash
# Set a specified wallpaper and apply colors (-s requires a name or path)
wp-color -s my-wallpaper.png

# Pick a random wallpaper from ~/.wallpapers and apply colors (same as wp-color -d)
wp-random

# Apply the current color scheme only (no wallpaper change, no re-extraction)
wp-color -a

# List available wallpapers / show the current color scheme
wp-color -l
wp-color -c
```

The default wallpaper `default.jpg` is applied automatically on first login; there is no dedicated command for it.

## Recommended Wallpaper Specifications

- Aspect ratio: 16:9 or 16:10
- Resolution: 1920x1080 or higher
- File format: PNG (lossless) or JPEG (compressed)

## Included Wallpapers

| File | Description |
|------|-------------|
| `default.jpg` | Default wallpaper (Chinese style dark theme, 1920x1080) |

## Default Wallpaper

The `default.jpg` file is used as the default wallpaper when no specific wallpaper is specified. It will be automatically applied during the first login.

**Style:** Chinese style / Dark theme
- Features traditional Chinese elements
- Deep, rich color palette
- Suitable for dark theme environments