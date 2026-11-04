# HL4W NixOS Configuration - Keyboard Shortcuts

**Version: v0.0.6**

This document details the keyboard shortcuts for Hyprland and Niri window managers, matching the actual configurations in `home/common/hyprland.nix` / `home/common/niri.nix`. Both window managers provide 5 workspaces by default.

---

## Hyprland Shortcuts

**Config summary**: master layout, gaps 5/10 (inner/outer), 2px border, animations enabled (windows, fade, workspaces), XWayland enabled.

### Basic Operations

| Shortcut | Function | Command Executed |
|----------|----------|------------------|
| `Super + Q` | Close active window | `killactive` |
| `Super + E` | Open file manager | `nemo` |
| `Super + R` | Open application launcher | `rofi -show drun` |
| `Super + Return` | Open terminal | `foot` |
| `Super + C` | Open editor | `codium` |
| `Super + B` | Open browser | `firefox` |
| `Super + P` | Open power menu | `rofi -show powermenu` |

### Window Focus Movement (arrow keys = hjkl)

| Shortcut | Function |
|----------|----------|
| `Super + H` | Move focus left |
| `Super + J` | Move focus down |
| `Super + K` | Move focus up |
| `Super + L` | Move focus right |

### Window Resizing (±10px per step)

| Shortcut | Function |
|----------|----------|
| `Super + Shift + H` | Shrink window left |
| `Super + Shift + J` | Expand window down |
| `Super + Shift + K` | Shrink window up |
| `Super + Shift + L` | Expand window right |

### Workspace Operations (5 total)

| Shortcut | Function |
|----------|----------|
| `Super + 1` – `Super + 5` | Switch to the corresponding workspace |
| `Super + Shift + 1` – `Super + Shift + 5` | Move active window to the corresponding workspace |

### Window State

| Shortcut | Function | Hyprland Command |
|----------|----------|------------------|
| `Super + F` | Toggle floating mode | `togglefloating` |
| `Super + F11` | Fullscreen | `fullscreen` (`FULL` is Hyprland's internal key alias) |
| `Super + Shift + F` | Swap position with next window | `swapnext` |
| `Alt + Shift + F` | Fake fullscreen (keeps borders and title) | `fakefullscreen` |

### Mouse Bindings

| Mouse Button | Function | Hyprland Command |
|--------------|----------|------------------|
| Left drag | Move window | `movewindow` |
| Middle drag | Resize window | `resizewindow` |
| Right click | Toggle floating mode | `togglefloating` |
| Back button (8) | Pass through to application (browser back, etc.) | `pass` |
| Forward button (9) | Pass through to application (browser forward, etc.) | `pass` |

---

## Niri Shortcuts

**Config summary**: gaps 8px, 2px border, workspace strip at top, XWayland enabled. Niri is a scrollable-tiling window manager; window focus/size are handled via scroll and gestures rather than extra directional keybinds.

### Basic Operations

| Shortcut | Function | Command Executed |
|----------|----------|------------------|
| `Super + R` | Open application launcher | `rofi -show drun` |
| `Super + Return` | Open terminal | `foot` |
| `Super + E` | Open file manager | `nemo` |
| `Super + B` | Open browser | `firefox` |
| `Super + Q` | Close window | — |
| `Super + C` | Open editor | `codium` |
| `Super + P` | Open power menu | `rofi -show powermenu` |
| `Super + Shift + Q` | Quit Niri | — |

---

## General Notes

### Super Key

In this configuration, `Super` refers to the **Windows key**; on macOS keyboards it maps to the **Command key**.

### Keyboard Layout

- Hyprland's XKB layout is set to `us` (`kb_layout = "us"`); Chinese input is handled by Fcitx5, so no separate CN layout is needed
- `Alt + Shift` is kept as the layout/IME toggle (`kb_options = "grp:alt_shift_toggle"`)

### Floating Window Rules

The following applications open in floating mode by default (Hyprland `windowrulev2`, matched by `class`):

| Application | class |
|-------------|-------|
| Foot terminal | `foot` |
| Kitty terminal | `kitty` |
| Alacritty terminal | `alacritty` |
| Rofi | `rofi` |
| Nemo file manager | `nemo` |

### Customizing Shortcuts

To modify shortcuts, edit the corresponding window manager configuration files:

- **Hyprland**: `home/common/hyprland.nix` (`keybinds` and `settings.windowrulev2`); system-level enablement in `modules/desktops/hyprland.nix`
- **Niri**: `home/common/niri.nix` (`settings.keybindings`); system-level enablement in `modules/desktops/niri.nix`

Apply changes with `home-manager switch --flake .#<username>@<hostname>`.
