# Glossary

This glossary defines the canonical terminology used throughout HL4W documentation. All English documents (README_en, `docs/*_en.md`) must follow this table; Chinese documents use the matching terms in [`glossary.md`](glossary.md).

> `docs/CHANGELOG.md` and `docs/CHANGELOG_EN.md` record historical facts and keep their original wording; they are not retrofitted.

## Product and versioning

| Canonical term | Code / identifier | Notes | Avoid |
|----------------|-------------------|-------|-------|
| HL4W (Hack Linux for Workflow) | — | Project name; spell out on first use | `Hack Linux`, `hl4w project` |
| configuration repository | — | What this repository is | config repo, dotfiles repo |
| NixOS 26.05 | `nixos-26.05` | Target release; spell out on first use | `26.05 system`, `NixOS 26` |
| Nix Flakes | `flake.nix`, `flake.lock` | Dependency locking and configuration entry point | `Flakes`, `flake file` (when meaning the entry point) |
| flake input | `inputs.*` | Flake dependency (nixpkgs, oh-my-rime, ...) | flake dependency, inputs |
| flake configuration name | `-N/--name`, `nixosConfigurations.<name>` | Configuration name used by the installer, defaults to the hostname | flake name |

## Configuration layers

| Canonical term | Code / identifier | Notes | Avoid |
|----------------|-------------------|-------|-------|
| system-level | `hosts/`, `modules/`, `nixosConfigurations` | NixOS configuration managed by root | system layer, root config |
| user-level | `home/`, `homeConfigurations` | Home Manager configuration managed by a regular user | user layer, normal config |
| Home Manager | `home-manager` (command) | User environment manager; do not abbreviate as "HM" in prose | HM, home manager |
| host | `hosts/<hostname>` | A managed device | machine, node, box |
| host type | `desktop`, `laptop`, `server` | Determines which modules are assembled | device type, machine type |

## Desktop components

| Canonical term | Code / identifier | Notes | Avoid |
|----------------|-------------------|-------|-------|
| window manager | `programs.hyprland`, `programs.niri` | Hyprland / Niri | WM |
| Lua config | `configType = "lua"`, `~/.config/hypr/hyprland.lua` | Hyprland 0.55+ official config format; when present `hyprland.conf` is ignored | lua config file, Lua script (when referring to config) |
| dispatcher | `hl.dsp.*` (e.g. `hl.dsp.window.close()`) | Function object that performs actions in Hyprland Lua | command, action command |
| workspace | `hl.dsp.focus({ workspace = N })` | Virtual desktop unit in Hyprland / Niri | desktop (when meaning virtual desktop) |
| desktop shell | option values `dms`, `noctalia` | Category of panel/shell components | Desktop Shell, shell component |
| DMS Shell | `dms-shell` (package/command), `programs.dms-shell` (module), `shell-dms.nix` | DankMaterialShell, lightweight desktop shell | DMS-Shell, DMS, dms shell |
| Noctalia Shell | `noctalia-shell` (v4 package), `shell-noctalia.nix` | Noctalia desktop shell (v4 currently used) | Noctalia-Shell, Noctalia, noctalia shell |
| polkit agent | `-P/--polkit-agent`, `kde`, `hyprland` | Privilege escalation agent | polkit-agent, polkit helper |
| input method | `fcitx5`, `rime`, `oh-my-rime` | Fcitx5 + RIME combination | IME, input framework |
| color scheme / theme | `catppuccin` | "theme" is the overall style, "color scheme" is the palette | skin, color theme |

## Installation and maintenance

| Canonical term | Code / identifier | Notes | Avoid |
|----------------|-------------------|-------|-------|
| installation script | `scripts/install.sh` | Generates host and user configuration | deploy script (when meaning this script) |
| disk setup script | `scripts/setup-disk.sh` | Partitioning, encryption, formatting, mounting | install script, formatting script |
| installer image | NixOS ISO | NixOS image used for a fresh install | install disk, USB installer |
| wallpaper color extraction | `wal` (pywal) | Extracting colors from a wallpaper | auto-color (generic), color grabbing |
| apply color scheme | `wal -R`, `wallpaper-color.sh` | Writing the palette into applications | update colors |
| generation | NixOS / Home Manager generations | Snapshot of a system or user configuration | version, release (when meaning generation) |
| old generation | `clean.sh -g` | Non-current generation snapshot | old version |
| placeholder | `youruser`, `Your Name` | Template value awaiting replacement | variable, placeholder field |
| disk encryption | LUKS2, `cryptsetup` | This project uses a LUKS2 container | hard drive encryption, encrypted disk |
| logical volume (LV) | `lvcreate`, `root`/`swap` | LVM logical volume (this project creates only an EFI and a data partition; the data partition becomes an LVM VG split into root and swap LVs, and `/home` lives under `/`) | partition (when meaning an LV) |

## Style rules

- Wrap code, commands, paths and option names in backticks, e.g. `scripts/install.sh`, `programs.dms-shell`, `home.stateVersion`.
- Chinese documents use full-width punctuation; English documents use half-width punctuation with a single space between sentences.
- Keep paired ordering consistent: **DMS Shell / Noctalia Shell**, **Hyprland / Niri**, **GTK / Qt**.
- Always write version numbers as `v0.0.6` (lowercase `v`).
- Use "desktop suite" when referring to the component bundle this repository provides; keep "desktop environment" for the desktop session itself.
