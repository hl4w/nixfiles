# HL4W NixOS Configuration - Keyboard Shortcuts

**Version: v0.0.6**

This document details the keyboard shortcuts for Hyprland and Niri window managers, matching the actual configurations in `home/common/hyprland.nix` / `home/common/niri.nix`. Both window managers provide 5 workspaces by default.

> Since Hyprland 0.55 the config format is **Lua** (Home Manager `configType = "lua"`, writing `~/.config/hypr/hyprland.lua`). The "Lua dispatcher" column below maps to `hl.dsp.*`.

---

## Hyprland Shortcuts

**Config summary**: Lua config format; master layout, gaps 5/10 (inner/outer), 2px border, 12px rounding, blur and shadows enabled; animations enabled (windows / fade / workspaces, speed 7); XWayland enabled.

### Basic Operations

| Shortcut | Function | Lua dispatcher |
|----------|----------|----------------|
| `Super + Q` | Close active window | `hl.dsp.window.close()` |
| `Super + E` | Open file manager | `hl.dsp.exec_cmd("nemo")` |
| `Super + R` | Open application launcher | `hl.dsp.exec_cmd("rofi -show drun")` |
| `Super + Return` | Open terminal | `hl.dsp.exec_cmd("foot")` |
| `Super + C` | Open editor | `hl.dsp.exec_cmd("codium")` |
| `Super + B` | Open browser | `hl.dsp.exec_cmd("firefox")` |
| `Super + P` | Open power menu | `hl.dsp.exec_cmd("rofi -show powermenu")` |

### Window Movement (arrow keys = hjkl)

| Shortcut | Function | Lua dispatcher |
|----------|----------|----------------|
| `Super + H` | Move window left | `hl.dsp.window.move({ direction = "left" })` |
| `Super + J` | Move window down | `hl.dsp.window.move({ direction = "down" })` |
| `Super + K` | Move window up | `hl.dsp.window.move({ direction = "up" })` |
| `Super + L` | Move window right | `hl.dsp.window.move({ direction = "right" })` |

### Window Resizing (±10px per step)

| Shortcut | Function | Lua dispatcher |
|----------|----------|----------------|
| `Super + Shift + H` | Shrink from the left | `hl.dsp.window.resize({ x = -10, y = 0, relative = true })` |
| `Super + Shift + J` | Grow downward | `hl.dsp.window.resize({ x = 0, y = 10, relative = true })` |
| `Super + Shift + K` | Shrink from the bottom | `hl.dsp.window.resize({ x = 0, y = -10, relative = true })` |
| `Super + Shift + L` | Grow to the right | `hl.dsp.window.resize({ x = 10, y = 0, relative = true })` |

### Workspace Operations (5 total)

| Shortcut | Function | Lua dispatcher |
|----------|----------|----------------|
| `Super + 1` – `Super + 5` | Switch to the corresponding workspace | `hl.dsp.focus({ workspace = N })` |
| `Super + Shift + 1` – `Super + Shift + 5` | Move active window to the corresponding workspace | `hl.dsp.window.move({ workspace = N })` |

### Window State

| Shortcut | Function | Lua dispatcher |
|----------|----------|----------------|
| `Super + F` | Toggle floating mode | `hl.dsp.window.float({ action = "toggle" })` |
| `Super + Shift + Return` | Toggle fullscreen | `hl.dsp.window.fullscreen({ action = "toggle" })` |
| `Super + Shift + F` | Swap position with next window | `hl.dsp.window.swap({ next = true })` |

### Mouse Bindings

Mouse bindings are registered via `hl.bind(..., { mouse = true; })`.

| Mouse Button | Function | Lua dispatcher |
|--------------|----------|----------------|
| `Super + Left drag` | Move window | `hl.dsp.window.drag()` |
| `Super + Middle drag` | Resize window | `hl.dsp.window.resize()` |
| `Super + Right click` | Toggle floating mode | `hl.dsp.window.float({ action = "toggle" })` |

---

## Niri Shortcuts

**Config summary**: gaps 8px, 2px border, workspace strip at top (showing workspace numbers and window titles), JetBrainsMono Nerd Font 14. Niri is a scrollable-tiling window manager; window focus/size are handled via scroll and gestures rather than extra directional keybinds.

### Basic Operations

| Shortcut | Function | Action |
|----------|----------|--------|
| `Super + Shift + Return` | Open terminal | `spawn "foot"` |
| `Super + D` | Open application launcher | `spawn "rofi -show drun"` |
| `Super + E` | Open file manager | `spawn "nemo"` |
| `Super + B` | Open browser | `spawn "firefox"` |
| `Super + Q` | Close window | `close-window` |
| `Super + C` | Open editor | `spawn "codium"` |
| `Super + P` | Open power menu | `spawn "rofi -show powermenu"` |
| `Super + Shift + E` | Power menu (Niri built-in action) | `power-menu` |
| `Super + Shift + Q` | Quit Niri | `quit` |

---

## General Notes

### Super Key

In this configuration, `Super` refers to the **Windows key**; on macOS keyboards it maps to the **Command key**.

### Keyboard Layout

- Hyprland's XKB layout is set to `us` (`settings.config.input.kb_layout = "us"`); Chinese input is handled by Fcitx5, so no separate CN layout is needed
- `Alt + Shift` is kept as the layout/IME toggle (`kb_options = "grp:alt_shift_toggle"`)

### Floating Window Rules

The following applications open in floating mode by default (Hyprland `settings.window_rule`, matched by `match.class` regex):

| Application | class regex |
|-------------|-------------|
| Foot terminal | `foot` |
| Kitty terminal | `kitty` |
| Alacritty terminal | `alacritty` |
| Rofi | `rofi` |
| Nemo file manager | `nemo` |

They are merged into a single rule: `match.class = "^(foot|kitty|alacritty|rofi|nemo)$"`, `float = true`.

### Customizing Shortcuts

To modify shortcuts, edit the corresponding window manager configuration files:

- **Hyprland**: `home/common/hyprland.nix` (`settings.bind` / `settings.window_rule` / `settings.config`, Lua format); system-level enablement in `modules/desktops/hyprland.nix`
- **Niri**: `home/common/niri.nix` (the `binds` block inside `xdg.configFile."niri/config.kdl"`); system-level enablement in `modules/desktops/niri.nix`

Hyprland key syntax joins modifiers with `" + "` (e.g. `"SUPER + SHIFT + Q"`); valid modifiers are `SHIFT` / `CTRL` / `ALT` / `SUPER` / `MOD1`–`MOD5`.

Apply changes with `home-manager switch --flake .#<username>@<hostname>`.
