# Changelog

All significant project changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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
