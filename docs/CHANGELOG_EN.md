# HL4W NixOS Configuration Changelog

All significant project changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

> Convention: when the version number stays the same, each commit opens a new section with the current date. All changes made on the same day are grouped under that section, so commits can be traced back to their day even before the next release is cut.

## [v0.0.6] - 2026-11-05
### Fixed
- **Invalid alias keys in `home/common/shell.nix`**: `syntax error, unexpected '.', expecting identifier or 'or' or '${' or '"'`. `cd..`, `..` and `...` are not valid Nix identifiers (`.` is not an identifier character and `...` is the function-argument ellipsis token), so they are now string attribute names `"cd.."` / `".."` / `"..."`; the system-level `environment.shellAliases` keys were checked and need no change
- **`qt6Packages` attribute audit against nixos-26.05 sources**: every `qt6Packages.*` reference in the code was checked. Neither the `qt6-packages.nix` scope file nor the `qt6` core module set provides `adwaita-qt` (it exists only as a top-level by-name package), so `qt6Packages.adwaita-qt` was removed from `modules/desktops/desktop.nix` and the existing `adwaita-qt` kept; `qt6Packages.fcitx5-qt`, `qt6Packages.fcitx5-chinese-addons` and `qt6Packages.fcitx5-configtool` are confirmed to be defined in that scope and were left unchanged
- **`infinite recursion encountered` (imports depending on config)**: `modules/desktops/desktop.nix` used `lib.optional (cfg.windowManager == ...)` for conditional imports. `imports` is evaluated before option merging, so referencing `config` creates a cycle. All desktop modules are now imported unconditionally and the condition moved into each module's own `lib.mkIf`: `hyprland.nix` / `niri.nix` keyed on `desktop.windowManager`, `shell-dms.nix` / `shell-noctalia.nix` on `desktop.shell`, and `input-method/default.nix` on `desktop.enableInputMethod`

## [v0.0.6] - 2026-11-04
### Fixed
- **flake.nix top-level `let` plus flake evaluator rejecting top-level `let`**: Two consecutive failed attempts. First, a `let ... in { ... }` was placed *inside* the attrset between properties — Nix reported `syntax error, unexpected 'let', expecting 'inherit'`. Second, moving `let ... in` to the outermost level still got rejected by the flake evaluator, which requires the flake.nix **top-level expression to be a plain attrset**. Final fix: top-level is now plain `{ ... }`, `nixConfig` inlines substituters / trusted-public-keys directly, and the two arrays are re-declared in the `outputs` inner `let` for `specialArgs` consumption. A file-top comment documents this flake evaluator constraint
- **Wrong Nix option path**: The SDDM config in `modules/desktops/unified-theme.nix` used `services.sddm` (does not exist in NixOS 26.05). Changed to `services.displayManager.sddm`, and fixed `config.services.sddm.enable` → `config.services.displayManager.sddm.enable`. This mistake would make Nix evaluation fail immediately
- **Missing `nixosConfigurations.<host>`**: `flake ... does not provide attribute 'nixosConfigurations.my-hostname'` is caused by the empty `nixosConfigurations` set in flake.nix — host entries are only written by `install.sh` when it runs from the repository root, and `my-hostname` is merely a documentation placeholder. `install.sh` / `install_en.sh` now self-locate: they `cd` into the repository root based on the script's own path (`BASH_SOURCE`), so the host config is written correctly no matter which directory the script is launched from; an incomplete layout (missing `flake.nix` / `hosts` / `home`) aborts with a clear error
- **Install failure where flakes are not enabled**: `experimental Nix feature 'nix-command' is disabled` was raised. Every nix invocation in `install.sh` / `install_en.sh` / `update.sh` / `update_en.sh` now goes through `NIX=(nix --extra-experimental-features "nix-command flakes")`, so it no longer depends on the target system's `nix.conf`; the `setup-disk.sh` / `setup-disk_en.sh` install instructions now include `sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-install --flake .#<host>`, and the FAQ documents all three workarounds
- **`lib.mkIf` wrapping a bare path inside `imports`**: `trying to define a value of type 'path' rather than an attribute set for the option ''` was raised. `(lib.mkIf cond ./x.nix)` in an `imports` list hands a raw path to the module system as a definition, which it cannot handle. Now written as `imports = [ ... ] ++ lib.optional cond ./x.nix` (`imports` accepts plain paths and list concatenation, but not nested lists)
- **Warning from `auto-optimise-store` in the flake `nixConfig`**: this is a restricted setting, so clients ignore it and print `ignoring the client-specified setting 'auto-optimise-store'`. It was removed from `nixConfig` and is now set solely through the system-level `nix.settings` in `modules/system/default.nix`
- **`undefined variable 'config'`**: `modules/desktops/unified-theme.nix` and `home/common/unified-theme.nix` referenced `config` while only declaring `{ pkgs, lib, ... }` as arguments; `config` is now bound. The unused top-level `let` block in the NixOS theme module (`getThemeMode` script and `lib.mkDefault` bindings) was removed as well
- **Non-existent SDDM options and outdated package names**: options such as `services.displayManager.sddm.greeterEnvironment` do not exist. In 26.05 `services.displayManager.sddm` only exposes 11 options (`enable`, `package`, `theme`, `settings`, `wayland`, `autoLogin`, ...), so neither `displayServer` nor `greeterEnvironment` is valid: `sddm.nix` drops `displayServer` (Wayland is selected via `wayland.enable`) and `unified-theme.nix` drops the whole greeter environment block. Package names were corrected too: `libappindicator-gtk3` (removed from nixpkgs) → `libayatana-appindicator`, `networkmanager-applet` → `networkmanagerapplet` (DMS and Noctalia modules)
- **`imports` placed inside `config` broke evaluation**: `The option 'imports' does not exist` was raised, defined in `modules/desktops/desktop.nix`. `imports` is a module-level attribute, not an option, so it cannot live inside a `config` block. It is now hoisted to the top level, and conditional logic no longer lives in `imports` (see the next entry); the conditional polkit agent packages in `environment.systemPackages` were also switched from `lib.mkIf` to `lib.optional` (a list element must be a package, not an attrset produced by `mkIf`)
- **`i18n.locales` option removed**: `The option 'i18n.locales' does not exist` was raised. The option was removed in NixOS 24.11; `modules/system/default.nix` now uses `i18n.extraLocales = [ "zh_CN.UTF-8" "en_US.UTF-8" ]` (plain locale names, without the ` UTF-8` charset suffix)
- **`boot.efi` option does not exist, breaking evaluation**: `The option 'boot.efi' does not exist` was raised. `modules/boot/default.nix` wrongly used `boot.efi` (no such option in NixOS) and `boot.loader.systemd-boot.efiSysMountPoint` (the option actually lives under `boot.loader.efi`). Now uses `boot.loader.efi.canTouchEfiVariables` and `boot.loader.efi.efiSysMountPoint = "/boot"`, and the invalid `boot.efi.enable` is removed
- **New host config not tracked by Git**: `Path 'hosts/<host>/configuration.nix' in the repository ... is not tracked by Git` — Nix only reads tracked files for flakes inside a git repository. `install.sh` / `install_en.sh` gained a `git_track()` helper that stages the generated host config, `flake.lock` and hardware configuration, plus a safety-net call before `nix flake check`; README option 3 and the FAQ now include the manual `git add` step
- **Unified disk layout on LVM**:
  - `setup-disk.sh` / `setup-disk_en.sh` create only an EFI and a data partition (the data partition is a LUKS2 container when encryption is enabled); `/` and `/home` are no longer separate partitions, `/` and swap are LVM logical volumes and `/home` lives under `/`
  - Swap LV size now scales with disk capacity (10% of the disk, clamped to 2–16 GiB) instead of a fixed 16 GiB
  - Added logical volume existence checks and `-y` on `pvcreate`/`lvcreate` so the script can be re-run safely

### Added
- **Installation guide website**: New `hl4w-install/` directory with two standalone bilingual HTML pages (`index.html` / `index_en.html`). Technical-installation-guide style with sticky sidebar TOC, three-option tabs, step cards, flag tables, collapsible FAQ, scroll-spy highlight and mobile-responsive layout

### Changed
- **oh-my-rime now defaults to the CNB mirror**: `inputs.oh-my-rime` switched its default source from `github:Mintimate/oh-my-rime/main` to `git+https://cnb.cool/Mintimate/rime/oh-my-rime` (verified reachable, same `main` default branch), with the GitHub upstream URL kept as a commented alternative for switching back; run `nix flake update oh-my-rime` after changing the source to refresh the lock entry. README, architecture and FAQ updated accordingly
- **flake.nix full audit and comment enhancement**: Fully audited against the NixOS 26.05 and Home Manager release-26.05 official specs (fetched HM's flake.nix source to confirm the `nixosModules.home-manager` path); verified all inputs align (`nixos-26.05` + `release-26.05`), the oh-my-rime source-input chain is complete (flake inputs → extraSpecialArgs → home/common/input.nix), and the cache-config variables in specialArgs are actually consumed by modules/system/default.nix; added comments for the USERNAME placeholder format constraint, the double inputs injection via extraSpecialArgs / specialArgs, and the empty nixosConfigurations default
- **Removed GitHub Actions CI**: Deleted `.github/workflows/build.yml` (remote CI is not needed at this stage); synced — removed the "Continuous Integration" section from `architecture.md` / `architecture_en.md`, and dropped the CI mentions from the README directory tree and documentation index

### Documentation
- **FAQ rewritten**: Added practical new questions — regenerating flake.lock, adding custom fonts, switching Catppuccin flavor, DMS Shell / Noctalia Shell configuration — and consolidated the previously scattered single-tool sections (dust, duf, tokei, hyperfine, procs) into one quick-reference table. Added non-interactive install.sh flag documentation; the desktop-shell section now points to the `desktop.shell` option and the actual NixOS module names; the wallpaper-colors-not-applying section gained a full troubleshooting checklist; troubleshooting expanded with more NixOS 26.05-specific issues (kdePackages/qt6Packages prefixes, etc.)
- **Shortcuts docs aligned with actual config**: Hyprland shortcut table now uses physical key names (`Super + F11` instead of Hyprland's internal `FULL` alias); floating rules document matched by `class`; each WM section gained a config summary (master layout, gaps, animations, XWayland); mouse bindings explain side-button passthrough to apps; Niri notes the top workspace strip; the whole file now states that it mirrors the Nix configuration and reminds users to run `home-manager switch` after edits
- **Reconciled the three install paths and script call chain**: README option 1 removed the redundant pre-clone step (`setup-disk.sh` clones into `/mnt/etc/nixos` and invokes `install.sh` itself), replaced with "download `setup-disk.sh` from the ISO → run it → cd to `/mnt/etc/nixos` and run `nixos-install`"; option 2 now lists every follow-up step explicitly (`nix flake update` on the first run, auto-generated `flake.lock`/hardware config, `nixos-rebuild switch --flake .#<hostname>`, optional `home-manager switch`); the closing banner of `setup-disk.sh`/`setup-disk_en.sh` now prints the repository location `/mnt/etc/nixos` explicitly so users do not run `nixos-install` from the wrong directory
- **Docs synced with the disk layout and call chain**: `glossary.md` logical-volume entry updated to `root`/`swap` with a note that `/home` lives under `/`; `migration.md` hardware-config check items now read "root LV `/dev/vg/root` / swap LV `/dev/vg/swap` / EFI boot partition"; `architecture.md` and `faq.md` initial-install examples describe the full chain: setup-disk.sh clones into `/mnt/etc/nixos` then calls install.sh to finish host config and hardware generation, so the ISO flow no longer requires a pre-cloned repo

## [v0.0.6] - 2026-11-02
### Fixed
- **Script robustness (all 14 scripts under `scripts/`)**:
  - `setup-disk.sh` / `setup-disk_en.sh` rewritten: fixed overlapping p3/p2 on the unencrypted path, `mkswap` running before the root filesystem was mounted, wrong partition naming for `/dev/sda` (now derived by `part_name()`), duplicated `mkfs`; added passphrase confirmation to the encrypted flow; replaced `eval` with array arguments
  - `setup-disk.sh` / `setup-disk_en.sh` added interactive selection: when `-T/-W/-S` are omitted, an interactive terminal prompts for host type / window manager / desktop shell (Enter keeps the default); `-y` or non-TTY stdin falls back to `desktop`/`hyprland`/`dms`; explicitly passed values are validated and invalid ones fail fast
  - `clean.sh` / `clean_en.sh`: fixed `-s`/`-g` clearing each other (which cleaned nothing); `nix store gc` now runs via `sudo` (the store is root-owned)
  - `update.sh` / `update_en.sh`: hostname now falls back to a detection chain; `-H` without an argument errors out; builds use the full attribute path `nixosConfigurations.<host>.config.system.build.toplevel`
  - `setup-direnv.sh` / `setup-direnv_en.sh`: install via `nix profile install nixpkgs#direnv` (`nix-env -iA nixos.*` is unavailable in flake setups); skip `direnv allow` when `.envrc` is absent; create directory and file before appending the hook
  - `wallpaper-color.sh` / `wallpaper-color_en.sh`: `find` arguments are now built as an array (the previous string concatenation made globs never match); fixed `local name=$(...)` declarations; `wal -R` failures no longer abort; hyprpaper applies the wallpaper to all monitors and the unverified `noctalia-shell`/`dms-shell` CLI flags were removed; `-h` no longer requires pywal
  - `wallpaper-watcher.sh` / `wallpaper-watcher_en.sh`: initialized `LAST_CACHE_MODIFIED` (previously uninitialized and broke numeric comparison); read the wallpaper path directly from `~/.cache/wal/wal`; a failed color extraction no longer kills the watcher; polling interval configurable via `WATCH_INTERVAL`
  - `install.sh` / `install_en.sh`: `youruser` placeholder replacement now escapes sed metacharacters and verifies the result; `POWER_MANAGEMENT` explicitly initialized; non-interactive mode (`-y`) fails fast on missing arguments instead of blocking on prompts; added validation for host type, window manager, desktop shell and polkit agent; `nixos-generate-config` automatically adds `--root /mnt` inside the installer; removed the Intel `i915.enable_psr=0` kernel parameter; build hints use the full attribute path
- **Fixed NixOS vs Home Manager module boundary confusion (critical)**:
  - `wayland.windowManager.hyprland` / `wayland.windowManager.niri` are Home Manager modules, not available in NixOS system config → Refactor: NixOS layer uses `programs.hyprland`/`programs.niri` for installation; detailed config moved to `home/common/hyprland.nix`/`niri.nix`
  - `gtk.*` / `xdg.iconTheme` are Home Manager options → moved from `modules/desktops/unified-theme.nix` to `home/common/unified-theme.nix`; system layer keeps only `qt`/`services.displayManager.sddm`/`environment.*`
  - NixOS `qt` module only supports `enable`/`platformTheme`/`style`; removed non-existent `qt.iconTheme`/`qt.font`
- **Removed non-existent NixOS options (critical)**:
  - Deleted `security.pam.enableSSS = false`
  - Deleted `security.faillock.enable = true`
  - Deleted `programs.noctalia-shell.enable` / `programs.dms-shell.enable` (packages, not module options)
- **Fixed Nix syntax errors (critical)**:
  - `services.display-manager` → `services.displayManager` (hyphen is not a valid Nix identifier; parsed as subtraction)
  - `services.sddm` → `services.displayManager.sddm` (`services.sddm` does not exist in NixOS and would fail evaluation)
- **Hyprland 0.55 (NixOS 26.05) compatibility**:
  - Removed `hyprnix` flake input, using native NixOS module
  - Added `configType = "hyprlang"` (0.55+ defaults to Lua)
  - `misc.xwayland = true` → `xwayland.enable = true`
  - Removed deprecated `hyprland-plugins.*` and standalone `xwayland` package
  - `kb_layout = "us,cn"` → `"us"` ("cn" is not a valid XKB layout; Chinese handled by fcitx5)
- **Home Manager 26.05 compatibility**:
  - Added `home.stateVersion = "26.05"` (HM 26.05 has no default; must be set explicitly)
  - `gtk.gtk4.theme` no longer mirrors `gtk.theme` by default; explicitly set `Adwaita-dark`
  - Fixed `gtk.theme.package`: `adwaita-icon-theme` (icon package) → `gnome-themes-extra` (Adwaita theme package)
- **Fixed deprecated/removed package names**:
  - `noto-fonts-cjk` → `noto-fonts-cjk-sans` + `noto-fonts-cjk-serif`
  - Removed non-existent `noto-fonts-emoji` (kept `noto-fonts-color-emoji`)
- **Fixed Home Manager option location error**:
  - `programs.yazi.shell.enableZoxideIntegration` → `programs.yazi.settings.shell.enableZoxideIntegration` (HM yazi module has no top-level shell option)
- **Fixed install.sh generated Home Manager config**:
  - Added imports for `unified-theme.nix` and the selected WM module (`hyprland.nix`/`niri.nix`)
- **Fcitx5 vs oh-my-rime conflict fix**:
  - Removed system-level `rime-data-*` packages
- **wallpaper-watcher.nix invalid options**:
  - Removed `systemd.user.enable = true`
- **Cleanup invalid config**:
  - Removed `allowedUDPPorts = [ 80 443 ]` (HTTP/HTTPS are TCP only)
  - Removed standalone `nvidia-settings` (included in driver)
- **Fixed font package reference causing build failure**:
  - `fonts.nix` `XDG_DATA_DIRS` still referenced the split-away `pkgs.noto-fonts-cjk` → now `noto-fonts-cjk-sans` + `noto-fonts-cjk-serif`
- **Fixed CI and build scripts**:
  - `.github/workflows/build.yml` watched branch `main` → `master` (matching the actual branch, otherwise CI never triggers)
  - `.github/workflows/build.yml` build targets `nix build .#desktop`/`.#laptop`/`.#server` (non-existent flake outputs) → evaluate with `nix flake check --no-build`, then discover `nixosConfigurations` dynamically and build the full attribute path `nixosConfigurations.<host>.config.system.build.toplevel`; if no host is declared, emit a warning and skip building
  - `.github/workflows/build.yml` rewritten as a single-job pipeline: added `concurrency` to cancel superseded runs on the same branch, passed the host list via `env` instead of interpolating it into the shell, and kept evaluation as the gate before building
  - `.github/workflows/build.yml` dropped the standalone `nix flake lock` step (committing `flake.lock` to the repo is recommended to pin dependencies) and enabled the `auto-allocate-uids` experimental feature
  - `Makefile` `switch-home` hardcoded placeholder `youruser@desktop` → now `USER`/`HOST` variables, supporting `make USER=<name> HOST=<host>`
  - `Makefile` `build` target `nix build .#$(HOST)` (non-existent flake output) → `nix build .#nixosConfigurations.$(HOST).config.system.build.toplevel`
- **Removed duplicated theme environment variables at system level**:
  - Removed `GTK_THEME`/`GTK2_RC_FILES`/`QT_STYLE_OVERRIDE`/`XDG_ICON_THEME` (higher priority than Home Manager user-level config; would override `gtk`/`xdg.iconTheme` modules)
- **Fixed desktop shell modules**:
  - `shell-dms.nix` now uses the official NixOS 26.05 `programs.dms-shell` module (brings dependencies and `dms.service` systemd startup) instead of installing the raw `dms-shell` package
  - `shell-noctalia.nix` removed `blueberry` (no longer in 26.05); `services.power-management.enable` (non-existent) → `powerManagement.enable`; added `services.upower.enable`; trimmed runtime deps already wrapped by the `noctalia-shell` package

### Changed
- **Clarified shell naming status**: In nixos-26.05 neither `dms-shell` nor `noctalia-shell` was renamed; upstream `dux-shell` (DMS 2.0) and `noctalia` v5 are new packages not backported to the 26.05 stable branch, so existing names are kept
- **Architecture refactor**: WM detailed config moved from NixOS system layer to Home Manager user layer, conforming to NixOS native module boundaries
- **Flake simplification**: Removed `hyprnix` flake input
- **Unified user group declarations**: `video`/`audio`/`docker` groups in `hosts/common/default.nix`
- **Unified terminal floating rules**: Added `foot` terminal floating rule to Hyprland windowrulev2
- **Updated architecture docs**: `architecture.md` and `architecture_en.md` synced with module boundary refactor

### Documentation
- **Added terminology glossary**: `docs/glossary.md` and `docs/glossary_en.md` define canonical terms, code identifiers and style rules
- **Unified documentation terminology**: README, architecture, FAQ, migration and shortcuts documents now use `DMS Shell` / `Noctalia Shell`, `Home Manager`, `generation`, `flake configuration name` consistently; `CHANGELOG` keeps historical wording untouched
- **Synced documentation content**: architecture inputs updated (oh-my-rime replaces hyprnix), font packages corrected (`noto-fonts-cjk-sans`/`serif`), glossary entries added to the docs index and `pkgs.lix` usage fixed; FAQ and migration guide now cover the `setup-disk.sh` install path, the `nix flake update` prerequisite, the full `nixosConfigurations` build attribute path and `clean.sh` flags; wallpaper commands unified as `wp-color -s/-d/-a/-l/-c` (removed non-existent `wp-apply`/`wp-list`, fixed the argument-less `wp-color -s` usage); SDDM option path corrected to `services.displayManager.sddm`; `powerManagement.cpuFreqGovernor` no longer prefixed with `services`; shortcuts docs point to `home/common/` for Hyprland/Niri configuration and now cover floating rules (including Foot) and keyboard layout
- **Generic documentation examples**: `setup-disk.sh` examples in README, architecture and FAQ now use `<disk>`/`<hostname>`/`<username>` placeholders and explain the interactive `-T/-W/-S` prompt and the `-c` no-encryption flag
- **README restructured**: features grouped into "Desktop & Appearance / Installation & System / Chinese & Office / Terminal & Development", new "Pre-deployment verification" and "Daily Operations" sections, unified terminology and full attribute-path guidance with duplicated paragraphs removed; the Chinese and English versions now share the same layout
- **Documented interactive selection and CI**: README and architecture describe the interactive `-T/-W/-S` prompts of `setup-disk.sh` and the `-y`/non-TTY fallbacks; architecture gained a "Continuous Integration" section covering `nix flake check --no-build`, dynamic host discovery and the full build attribute path, plus a recommendation to commit `flake.lock`

## [v0.0.5] - 2026-06-16
### Added
- **GPL v3.0 License Update**: Verified and confirmed the project uses the complete GNU General Public License v3.0
- **Documentation Version Unification**: Updated all documentation files to version v0.0.5
  - `flake.nix` - Flake entry file version update
  - `docs/architecture.md` - Architecture documentation version update
  - `docs/architecture_en.md` - Architecture documentation (English) version update
- **Author Information**: Added author information "Author: Silas Zhang (2026)" to README documentation and all script files
- **Bash Shell Support**: Added complete Bash configuration support
  - System-level Bash installation and enablement (`modules/system/default.nix`)
  - User-level Bash configuration (`home/common/shell.nix`)
  - Starship prompt integration with Bash
  - Bash and Zsh share the same environment variables and alias configuration
- **Repository Name Update**: Changed repository name from `nixfiles26` to `nixfiles`
- **Repository URL Update**: Added dual repository URLs for Gitee and GitHub
  - Chinese users: `https://gitee.com/hl4w/nixfiles.git`
  - International users: `https://github.com/hl4w/nixfiles.git`
- **Keyboard Shortcuts Documentation**: Created Hyprland/Niri keyboard shortcuts reference documentation
  - `docs/shortcuts.md` - Chinese shortcuts documentation
  - `docs/shortcuts_en.md` - English shortcuts documentation
- **Firefox Shortcut**: Added `Super+B` to open Firefox browser
- **Unified Application Shortcuts**: Unified application shortcuts configuration between Hyprland and Niri
  - `Super+R` - Application launcher (Rofi)
  - `Super+Return` - Terminal (Foot)
  - `Super+E` - File manager (Nemo)
  - `Super+B` - Firefox browser
  - `Super+Q` - Close window
  - `Super+C` - VSCodium
  - `Super+P` - Power menu (Rofi)
  - `Super+Shift+Q` - Quit window manager
- **VSCodium Support**: Added VSCodium (open-source VS Code) as the default editor
  - User-level `vscodium` package installation (`home/common/apps.nix`)
  - Shortcut `Super+C` to open VSCodium
- **Script Shebang Update**: Updated all sh script shebangs from `#!/bin/sh` to `#!/usr/bin/env bash` to ensure proper bash syntax execution
### Changed
- **License Verification**: Confirmed LICENSE file content complies with GNU GPL v3.0 standard text
- **Image viewer replacement**: Replaced `eog` (Eye of GNOME, GTK3) with `loupe` (official GNOME successor, GTK4/LibAdwaita, Wayland-native) in `home/common/apps.nix`; visually consistent with evince/nemo and supports HEIF/AVIF/JPEG XL. Architecture, FAQ, and migration docs (both languages) updated accordingly
- **NetworkManager tooling optimization (NixOS 26.05)**:
  - Moved VPN plugins from `home/hosts/laptop/default.nix` (user-level `home.packages`) to `hosts/laptop/configuration.nix` via `networking.networkmanager.plugins`, since the NM daemon runs as root and can only load system-level plugins
  - Added `networkmanager-openvpn` (most common VPN protocol)
  - Enabled `networking.networkmanager.wifi.powersave = true` (laptop WiFi power saving, officially recommended by NixOS)
  - Confirmed `nmcli`/`nmtui` are auto-installed with `networking.networkmanager.enable = true`, no separate declaration needed
- **oh-my-rime input method config framework refactor**: Changed oh-my-rime from `home.packages` (not a nixpkgs package, causes evaluation error) to a flake input (`github:Mintimate/oh-my-rime/main`); deploys schema/dict/lua files via symlinks to `~/.local/share/fcitx5/rime/` using `home.file`; uses `default.custom.yaml` to override `schema_list` and lets RIME auto-generate the writable `installation.yaml`
- **Added Fcitx5 Catppuccin theme**: Added `catppuccin-fcitx5` to `fcitx5.addons` in `modules/input-method/default.nix`, configured `Theme=catppuccin-mocha-mauve` via `~/.config/fcitx5/conf/classicui.conf` through `home.file`; supports 4 flavors (latte/frappe/macchiato/mocha) × 14 accent colors
### Fixed
- **Fixed FLAKE_NAME not quoted causing nix syntax error in install.sh**: `scripts/install.sh` and `scripts/install_en.sh` inserted host entries into the `nixosConfigurations` block of `flake.nix` with unquoted attribute names (e.g. `my-desktop-config = mkHost "my-desktop";`). Nix parses unquoted attribute names containing hyphens as subtraction (`my - desktop - config`), causing `nix flake check` and `nixos-rebuild` to fail. Now generates `"${FLAKE_NAME}" = mkHost "${HOSTNAME}";` instead
- **Fixed fragile sed substitution in install.sh**:
  - Added `sed_escape_replacement()` helper to escape `\`, `&`, `/` in replacement strings, preventing sed breakage when username/email/hostname contain metacharacters
  - sed substitutions for Git username, email, and flake.nix username now use precise field-level patterns (e.g. `userName = "Your Name"`) with placeholder existence checks for idempotent runs: repeated execution no longer silently does nothing but emits a `warn` notice
  - Moved `sed_escape_replacement()` definition to the helper functions area, preventing it from being defined after its first use
- **Fixed flake.nix host entry insertion logic in install.sh**:
  - Replaced the `a \\...\\\n` sed append command (complex escaping, inconsistent across sed versions) with `awk index()` matching the `nixosConfigurations = {` line for precise insertion
  - Switched `grep` detection to `grep -qF` fixed-string matching, eliminating the 4-space vs 6-space indentation mismatch
  - Added post-insertion verification: fails fast with `error` instead of silently continuing on insertion failure
- **Fixed NetworkManager DNS option path in network.nix**: `services.networkmanager.dns` does not exist in NixOS; the correct path is `networking.networkmanager.dns`, meaning the DNS management setting was not taking effect. Corrected to `networking.networkmanager.dns = "systemd-resolved"`
- **Fixed oh-my-rime fetch and configuration errors in input.nix**:
  - `home.packages = [ oh-my-rime ]`: oh-my-rime is not a nixpkgs package, causing Nix evaluation error
  - `fetchFromGitHub { owner = "lotem"; rev = "master"; sha256 = fakeSha256 }`: actual repo is `Mintimate/oh-my-rime` with default branch `main`, and `fakeSha256` is a dev placeholder that fails to build
  - `schema_list` in `installation.yaml` referenced `luna_pinyin_simp`, `flypy`, `bopomofo` which do not exist in oh-my-rime (actual schemes: `rime_mint`, `rime_mint_flypy`, etc.)
  - `__patch` referenced `default.custom.yaml`, `luna_pinyin.custom.yaml`, `key_bindings.custom.yaml` etc. which do not exist in the oh-my-rime repo
  - Config files were written to `~/.config/rime/` via `xdg.configFile."rime/..."`, but fcitx5-rime's actual data directory is `~/.local/share/fcitx5/rime/`
## [v0.0.4] - 2026-06-15

### Added

- **Script Standardization**: Unified structure and style across all shell scripts
  - Added consistent color variables (RED, GREEN, YELLOW, NC)
  - Standardized logging functions (`info()`, `warn()`, `error()`)
  - Added `confirm()` function with non-interactive mode support
  - Added `usage()` function for displaying help information
  - Added HL4W branding to all scripts
- **update.sh Enhancement**: Added hostname parameter support for specifying target host for build
- **setup-direnv.sh Enhancement**: Added automatic Shell type detection, supporting bash/zsh/fish
- **Script Synchronization**: Ensured all Chinese and English script versions have identical functionality

### Changed

- **install.sh/install_en.sh Synchronization**: Updated English version to match all improvements from Chinese version (host backup, flake validation, update command documentation)
- **clean.sh/clean_en.sh Optimization**: Updated confirm function with non-interactive mode support

## [v0.0.3] - 2026-06-15

### Added

- **Enhanced CLI Toolset**: Added more modern command-line tools
  - `yazi` - Fast terminal file manager (written in Rust)
  - `dust` - Disk usage analysis tool
  - `duf` - Disk space viewer
  - `tokei` - Code statistics tool
  - `hyperfine` - Command performance testing tool
  - `procs` - Enhanced ps command
  - `zoxide` - Smart directory navigation tool
- **Yazi Configuration Integration**: Configured Yazi file manager in `home/common/cli.nix` with zoxide integration
- **Zoxide Navigation**: Enabled Zoxide smart directory jumping in `home/common/cli.nix`
- **Wallpaper Repository**: Added full wallpaper collection download URL `https://github.com/hl4w/wallpaper.git` to `wallpapers/README.md`
- **Project Version Update**: Updated version number to v0.0.3 across all documentation files

### Changed

- **CLI Tools Modularization**: Separated CLI tools from `apps.nix` into a dedicated `home/common/cli.nix` module for clearer structure
- **shell.nix Streamlined**: Removed duplicate configurations with CLI module to maintain separation of concerns
- **Documentation Updates**: Updated README, architecture docs, FAQ, and migration guide to reflect the latest project status
- **Wallpaper README Updated**: Updated file list in `wallpapers/README.md` to only include actual existing `default.jpg`

### Fixed

- **Fixed Lix Configuration**: Corrected Lix reference in `modules/system/default.nix`, using `pkgs.lix` instead of `pkgs.lixPackageSets.stable.lix`
- **Fixed Directory Structure Documentation**: Updated directory tree in architecture documentation to match actual file structure
- **Fixed Wallpaper README**: Corrected default wallpaper filename from `default.png` to `default.jpg`

## [v0.0.2] - 2026-06-14

### Added

- **GPU Auto-Detection**: Added lspci hardware detection in install.sh
  - NVIDIA GPU: Automatically adds `modules/hardware/nvidia.nix` import and kernel parameters
  - AMD/ATI GPU: Automatically adds `amdgpu.si_support=1` and `amdgpu.cik_support=1` kernel parameters
  - Intel integrated GPU: Automatically adds `i915.enable_psr=0` kernel parameter
  - Unknown GPU uses generic configuration
- **English Version Support**: Created English versions for all scripts
  - `scripts/install_en.sh` - Installation script (English)
  - `scripts/wallpaper-watcher_en.sh` - Wallpaper watcher script (English)
  - `scripts/wallpaper-color_en.sh` - Wallpaper color script (English)
  - `scripts/setup-disk_en.sh` - Disk setup script (English)
  - `scripts/clean_en.sh` - Cleanup script (English)
  - `scripts/update_en.sh` - Update script (English)
  - `scripts/setup-direnv_en.sh` - direnv setup script (English)
- **English Documentation**: Created English versions of project documentation
  - `README_en.md` - Project README (English)
  - `docs/CHANGELOG_EN.md` - Changelog (English)
  - `docs/architecture_en.md` - Architecture documentation (English)
  - `docs/faq_en.md` - FAQ documentation (English)
  - `docs/migration_en.md` - Migration guide (English)
- **Development Language LSP Support**: Added complete language support for Go, Python, Rust, and C/C++ (user-level configuration)
  - **C/C++**: clangd, clang-tools, cmake, ninja, gdb, lldb
  - **Go**: go, gopls
  - **Python**: python3, pyright
  - **Rust**: rustc, rust-analyzer, rustfmt, cargo
- **Neovim LSP Configuration**: Configured LSP servers for all supported languages (nil_ls, clangd, gopls, pyright, rust_analyzer)

### Changed

- **NixOS 24.11+ Graphics Configuration**: Replaced `hardware.opengl` with `hardware.graphics`
  - `hardware-common.nix` uses `hardware.graphics.enable = true`
  - install.sh generates GPU generic configuration during installation
  - Simplified OpenGL configuration (`driSupport` and similar options are now auto-enabled)
- **Audio Configuration Modularization**: Consolidated audio config to `modules/hardware/sound.nix`
  - Contains rtkit (real-time audio service), PipeWire (modern audio server), PulseAudio compatibility
  - `hardware-common.nix` simplified, only contains reference comment
- **Desktop Configuration Optimization**: Refactored `desktop-common.nix`, separated defaults from host-specific config
  - `modules/desktops/desktop.nix` provides desktop option defaults
  - `hosts/common/desktop-common.nix` only contains generic config (user groups, etc.)
  - install.sh generates host-level config based on user selection
- **Documentation Structure Optimization**: Moved changelog to `docs/` directory
  - `CHANGELOG.md` → `docs/CHANGELOG.md`
  - `CHANGELOG_EN.md` → `docs/CHANGELOG_EN.md`
- **Unified Documentation Naming Convention**: Changed English document naming from `.en.md` to `_en.md`
  - `README.en.md` → `README_en.md`
  - `docs/architecture.en.md` → `docs/architecture_en.md`
  - `docs/faq.en.md` → `docs/faq_en.md`
  - `docs/migration.en.md` → `docs/migration_en.md`
- **Updated README**: Fixed documentation links from `.zh.md` to `.md`
- **Updated Architecture Documentation**: Enhanced directory structure tree with all actual files:
  - `modules/boot/plymouth.nix` - Plymouth boot animation configuration
  - `modules/hardware/firmware.nix` - Additional firmware support
  - `modules/hardware/nvidia.nix` - NVIDIA graphics driver configuration
  - `modules/hardware/sound.nix` - Audio system configuration
  - `home/common/wallpaper-watcher.nix` - Wallpaper watcher user service
  - `secrets/example.age` and `secrets/README.md`
  - All wallpaper files in `wallpapers/` directory
- **Updated Project Version**: Updated `flake.nix`, `README.md`, `README_en.md` to v0.0.2
- **NixOS 26.05 Compatibility**: Updated `breeze-icons` package reference from `pkgs.breeze-icons` to `pkgs.kdePackages.breeze-icons` for better KDE package version compatibility
- **Modern System Tools**: Replaced `htop` with `btop` (modern system monitoring) and added `fastfetch` (fast system info display) at user level
- **Extended Font Support**: Added `noto-fonts-color-emoji`, `fira-code`, `source-code-pro`, `iosevka`, `font-awesome` font packages
- **Added Spell Checker**: System-level installation of `nuspell` engine (3x faster than Hunspell) with English dictionaries (`hunspellDicts.en-us`, `hunspellDicts.en-gb-ise`). Note: Nuspell/Hunspell does not support Chinese spell checking
- **Optimized Boot Configuration**:
  - Removed explicit `boot.initrd.systemd.enable` (enabled by default in NixOS 26.05)
  - Added quiet boot kernel parameters: `quiet`, `splash`, `rd.udev.log_level=3`, `rd.systemd.show_status=auto`
  - Set `boot.consoleLogLevel = 3` and `boot.initrd.verbose = false` to reduce boot logging
  - Consolidated `loader.efi` and `loader.systemd-boot` configurations
  - Explicitly disabled other bootloaders (grub, generic-extlinux-compatible)
- **Use Lix High-Performance Nix**: Replaced default `nix.package` with `pkgs.lixPackageSets.stable.lix`, using overlay to ensure Nix-dependent tools also use Lix for better eval and fetch performance
- **Niri Uses Official Package**: Removed `niri` from flake inputs, now using `pkgs.niri` from NixOS 26.05 official repository
  - Removed `niri.url = "github:YaLTeR/niri/main"` from `flake.nix`
  - Updated `modules/desktops/niri.nix` to use `pkgs.niri` instead of `inputs.niri.packages.x86_64-linux.niri`

## [v0.0.1] - 2026-06-11

### Added

- **Unified Theme Configuration Module** (`unified-theme.nix`)
  - GTK, Qt, Hyprland, Niri, Noctalia-Shell, DMS-Shell, SDDM share the same color scheme and icon style
  - Theme: Adwaita-dark (dark mode) / Adwaita (light mode)
  - Icons: Papirus-Dark / Papirus
  - Font: Noto Sans CJK SC 11pt (Chinese support)
  - Window borders: green for active windows (rgba(34, 197, 94)), gray for inactive windows (rgba(71, 85, 105))
- **Automatic Wallpaper Color Extraction System** (pywal)
  - Supports extracting colors from wallpaper and applying to terminal, shell, and editor
  - Created `scripts/wallpaper-color.sh` script
  - Command aliases: `wp-color`, `wp-random`, `wp-apply`, `wp-list`
- **Day/Night Theme Auto-switching**
  - Supports automatic switching between light/dark themes based on time (6:00-18:00 as daytime)
  - Command line tools: `theme-auto`, `theme-dark`, `theme-light`
  - Configurable day/night switching times
- **Terminal Emulators**: Added kitty and foot terminals (alongside alacritty)
- **User-level C/C++ Development Support**: clangd, clang-tools, cmake, ninja, gdb, lldb
- **Optimized `host-template/configuration.nix`**: Added optional module comments for better effectiveness
- **Nextcloud Client**: Added `nextcloud-client` package at user level for cloud file sync
- **Integrated Nemo-related packages at user level**: nemo, nemo-extensions, evince, eog managed in `home/common/apps.nix`
- **Default terminal changed to foot**: Changed default terminal from kitty to foot for Hyprland and Niri (lightweight high-performance terminal)
- **Dynamic Desktop Environment Identification**: `unified-theme.nix` supports automatic `XDG_CURRENT_DESKTOP` environment variable based on window manager
- **Refactored Host-specific Package Configuration**: Moved desktop/laptop specific packages from `install.sh` to separate user-level configuration files
- **Separated System-level and User-level Configuration**: `/hosts/` directory contains only system-level configs, `/home/hosts/` contains user-level configs
- **Desktop Configuration Module** (`modules/desktops/desktop.nix`): Supports dynamic selection of window manager (hyprland/niri), desktop shell (dms/noctalia), and polkit agent (kde/hyprland) without modifying imports
- **Mouse Side Button Support**: Added `pass` bindings (Button 8/9) in Hyprland for proper back/forward handling in applications like Nemo and Firefox
- **Updated Qt Package Names**: Adapted to NixOS 26.05 package repository (`adwaita-qt` → `qt6Packages.adwaita-qt`, `qt6-multimedia` → `qt6Packages.qtmultimedia`, `fcitx5-qt` → `qt6Packages.fcitx5-qt`, `qtwayland` → `qt6Packages.qtwayland`)

### Changed

- Renamed `display-manager.nix` to `sddm.nix` for future expansion to other display managers (e.g., LightDM, GDM)
- Removed X11 support from fcitx5, keeping only Wayland support
- Moved `input-method.nix` from `hardware/` directory to `modules/` root directory
- Removed podman, keeping only docker (for desktop use)
- Replaced Thunar with Nemo (supports PDF/image preview)
- Replaced Wofi with Rofi (better Wayland support)
- Replaced Exa with Eza (exa is deprecated)
- Replaced LibreOffice with WPS Office CN (Chinese version with better Chinese support)
- **Optimized Font Configuration**
  - Created separate `modules/system/fonts.nix` module, separating font config from theme config
  - Default font uses English (Noto Sans) with FontConfig fallback for Chinese
  - Added WPS Office CN font alias mappings (SimSun, SimHei, Microsoft YaHei, etc.)
  - Installed complete Chinese fonts: Noto CJK, Source Han, WenQuanYi
- Removed Waybar, using window manager built-in status bar
- **Optimized Module Structure, Removed Duplicate Package Installations**
  - Merged duplicate `environment.systemPackages` blocks in `unified-theme.nix`
  - Cleaned up duplicate packages in `hyprland.nix`, `niri.nix` that exist at user level
  - Removed redundant `wallpaper-color.nix` file (content already merged)
- **Refactored Project Structure, Organized Modules by Function**
  - Created `modules/system/` directory for system base configuration
  - Created `modules/services/` directory for network, security, virtualization service configuration
  - Created `modules/input-method/` directory for input method configuration
  - Used `default.nix` as module entry point to simplify import paths
- **Improved Helper Scripts**
  - `scripts/clean.sh`: Added command line argument support, supports cleaning store or old generations separately
  - `scripts/update.sh`: Added automatic build configuration selection based on hostname
  - `scripts/setup-disk.sh`: Added complete command line argument support, supports optional encryption, custom repository URL, passing host type/window manager/desktop shell parameters
  - `scripts/wallpaper-color.sh`: Improved bash detection logic, supports project wallpaper directory and user wallpaper directory, added color output logging functions, supports more wallpaper formats (jpg, jpeg, png, gif, webp)
- **Added Wallpaper Folder**
  - Created `wallpapers/` directory for wallpaper files
  - Default wallpaper is a Chinese-style majestic landscape in deep tones (`default.jpg`)
  - Updated `home/common/shell.nix` to automatically copy wallpaper directory to user directory
  - Updated `modules/desktops/unified-theme.nix` to add automatic wallpaper directory creation support
  - Updated `scripts/wallpaper-color.sh` to support reading wallpapers from project directory, added wallpaper setting and color scheme support for Noctalia-Shell and DMS-Shell
- **Added Wallpaper Change Monitoring Service**
  - Created `scripts/wallpaper-watcher.sh` script to monitor wallpaper changes
  - Created `home/common/wallpaper-watcher.nix` Home Manager module
  - Supports automatic color scheme update when wallpaper is selected via Noctalia-Shell/DMS-Shell interface
- Checked all Nix code against NixOS 26.05 syntax
- **Optimized Mouse Side Button Configuration**: Added `pass` bindings (Button 8/9) in Hyprland for proper back/forward handling in applications like Nemo and Firefox
- **Updated Qt Package Names**: Adapted to NixOS 26.05 package repository (`adwaita-qt` → `qt6Packages.adwaita-qt`, `qt6-multimedia` → `qt6Packages.qtmultimedia`, `fcitx5-qt` → `qt6Packages.fcitx5-qt`)
- **Created Mouse Configuration Module**: `modules/hardware/mouse.nix` documenting mouse button numbering and side button handling strategy

### Fixed

- Fixed fcitx5 package name issues: `fcitx5-chinese-addons` and `fcitx5-configtool` require `qt6Packages` prefix
- Fixed mouse side button Button 8/9 not working: Added `pass` bindings in Hyprland to pass events to applications
- Fixed `exa` command alias in `home/common/shell.nix`, changed to `eza`
- Fixed `qtwayland` package reference, requires `kdePackages` prefix
- Fixed `polkit-kde-agent` package reference, requires `kdePackages.polkit-kde-agent-1`
- Fixed `youruser` placeholder issues in code
- Fixed install.sh and flake.nix host type configuration conflict
- **Fixed invalid `fonts.fontconfig.extraFonts` option in `modules/system/fonts.nix`**: Changed to `fonts.fontconfig.localConf` for XML font alias mapping, moved font packages from `environment.systemPackages` to `fonts.packages`
- **Fixed incomplete configuration generation in `install.sh`**: Added `polkitAgent` option support, initialized `POWER_MANAGEMENT` variable to avoid undefined behavior
- **Fixed duplicate `environment.systemPackages` definition in `modules/desktops/unified-theme.nix`**: Merged into a single `lib.mkAfter` block to avoid NixOS configuration merge conflicts
- **Fixed invalid `programs.language-servers` option in `home/common/dev-lsp.nix`**: Removed non-existent Home Manager option, kept only `home.packages`
- **Fixed invalid `programs.fcitx5` option in `home/common/input.nix`**: Removed non-existent Home Manager option, kept `xdg.configFile` RIME configuration
- **Fixed duplicate `environment.etc` definition in `modules/desktops/unified-theme.nix`**: Merged wallpaper directory and GTK/Qt config files into the same `environment.etc` block

### Removed

- Removed Stylix theme framework
- Removed Xorg tools (xorg.xinit, xorg.xrandr)
- Removed unnecessary display managers (kept SDDM)
- Removed overlays directory (unused)
- Removed all hardware configuration template files (now auto-generated during installation)

## [2026-06-10]

### Added

- Project initialization: Modern configuration repository based on NixOS 26.05
- Hyprland 0.55.2 window manager configuration (managed via hyprnix)
- Niri window manager configuration
- DMS-Shell lightweight desktop shell
- Noctalia-Shell modern desktop integration shell
- Fcitx5 + RIME input method configuration (using oh-my-rime)
- Unified GTK/Qt theme and icon configuration
- Interactive installation script (scripts/install.sh)
- SDDM display manager configuration (Wayland mode only)
- User-level tool configuration (neovim, emacs, yazi, vlc, eza, bat)
- UEFI boot configuration (systemd-boot, keeping 3 boot options)
- Modular architecture: System config, user config, hardware config separated
- Domestic mirror configuration (USTC, Tsinghua, BFSU mirrors) to accelerate binary package downloads
- Installation script supports automatic hardware configuration generation

### Changed

- License changed from MIT to GNU GPL v3.0

### Fixed

- Fixed duplicate package definition issue in `home/common/input.nix`

## [2026-06-09]

### Added

- Completed installation script (scripts/install.sh) development
  - Supports username, hostname, Git information input
  - Supports host type selection (Desktop/Laptop/Server)
  - Supports window manager selection (Hyprland/Niri)
  - Supports desktop shell selection (DMS-Shell/Noctalia-Shell)
  - Automatically generates host and user configurations

### Changed

- Optimized project structure, modularized configuration files
- Updated flake.nix to use `mkHost` function for unified host configuration management

## [2026-06-08]

### Added

- Configured Hyprland using Lua syntax
- Added Niri window manager module
- Added DMS-Shell and Noctalia-Shell modules
- Added unified theme configuration (GTK/Qt/icons)

### Changed

- Removed stylix theme framework

## [2026-06-07]

### Added

- Initialized project structure
- Added basic system modules (common.nix, security.nix, network.nix)
- Added hardware modules (bluetooth, input method)
- Added Home Manager user configuration
