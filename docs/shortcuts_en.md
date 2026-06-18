# HL4W NixOS Configuration - Keyboard Shortcuts

**Version: v0.0.5**

This document details the keyboard shortcuts for Hyprland and Niri window managers.

---

## Hyprland Shortcuts

### Basic Operations

| Shortcut | Function |
|----------|----------|
| `Super + Q` | Close active window |
| `Super + E` | Open file manager (Nemo) |
| `Super + R` | Open application launcher (Rofi) |
| `Super + Return` | Open terminal (Foot) |
| `Super + C` | Open VS Code |
| `Super + W` | Open Firefox browser |
| `Super + P` | Open power menu (Rofi) |

### Window Focus Movement

| Shortcut | Function |
|----------|----------|
| `Super + H` | Move focus left |
| `Super + J` | Move focus down |
| `Super + K` | Move focus up |
| `Super + L` | Move focus right |

### Window Resizing

| Shortcut | Function |
|----------|----------|
| `Super + Shift + H` | Resize window left (shrink) |
| `Super + Shift + J` | Resize window down (expand) |
| `Super + Shift + K` | Resize window up (shrink) |
| `Super + Shift + L` | Resize window right (expand) |

### Workspace Operations

| Shortcut | Function |
|----------|----------|
| `Super + 1` | Switch to workspace 1 |
| `Super + 2` | Switch to workspace 2 |
| `Super + 3` | Switch to workspace 3 |
| `Super + 4` | Switch to workspace 4 |
| `Super + 5` | Switch to workspace 5 |
| `Super + Shift + 1` | Move window to workspace 1 |
| `Super + Shift + 2` | Move window to workspace 2 |
| `Super + Shift + 3` | Move window to workspace 3 |
| `Super + Shift + 4` | Move window to workspace 4 |
| `Super + Shift + 5` | Move window to workspace 5 |

### Window State

| Shortcut | Function |
|----------|----------|
| `Super + F` | Toggle floating mode |
| `Super + Full` | Fullscreen |
| `Super + Shift + F` | Swap window position |
| `Alt + Shift + F` | Fake fullscreen |

### Mouse Bindings

| Mouse Button | Function |
|--------------|----------|
| Left click | Move window |
| Middle click | Resize window |
| Right click | Toggle floating mode |
| Back button (8) | Pass through to application (back) |
| Forward button (9) | Pass through to application (forward) |

---

## Niri Shortcuts

### Basic Operations

| Shortcut | Function |
|----------|----------|
| `Super` | Open application launcher (Rofi) |
| `Super + Return` | Open terminal (Foot) |
| `Super + E` | Open file manager (Nemo) |
| `Super + B` | Open Firefox browser |
| `Super + W` | Close window |
| `Super + Shift + Q` | Quit Niri |

---

## Key Definitions

### Super Key

In this configuration, the `Super` key typically refers to the **Windows key** or **Command key** (on macOS keyboards).

### Keyboard Layout Switching

- Switch keyboard layout: `Alt + Shift`
- Supports English (US) and Chinese (CN) layouts

### Floating Window Rules

The following applications open in floating mode by default:

- Kitty terminal
- Alacritty terminal
- Rofi (application launcher, power menu)
- Nemo file manager

---

## Customizing Shortcuts

To modify shortcuts, edit the corresponding window manager configuration files:

- Hyprland: `modules/desktops/hyprland.nix`
- Niri: `modules/desktops/niri.nix`