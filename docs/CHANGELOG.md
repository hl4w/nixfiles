# HL4W NixOS Configuration Changelog

所有重要的项目变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

> 约定：版本号不变时，每次提交均以**当日日期**开一个新的小节，当日所有改动聚合在该节下，便于按日期追踪未发布版本的变更。

## [v0.0.6] - 2026-11-09
### Fixed
- **desktop 主机构建已通过（`nixos-rebuild build` 成功）**: 经过约 20 处修复（infinite recursion、26.05 选项/包名变更、整数插值、环境变量冲突等），`nixosConfigurations.nixos`（desktop 主机）的 flake 构建首次成功。下一阶段开始逐主机调试 laptop 与 server
- **`QT_QPA_PLATFORMTHEME` 手动设置与 `qt.platformTheme = "gnome"` 冲突**（`modules/desktops/unified-theme.nix`）: NixOS 的 `qt` 模块启用后会自动把 `environment.variables.QT_QPA_PLATFORMTHEME` 设为 `platformTheme` 的值（`"gnome"`），我们手动设了 `"gtk3"` 就产生冲突定义。删除手动那行，让 qt 模块统一管理
- **`liberation-fonts` 包名已改**（`modules/system/fonts.nix`）: nixos-26.05 里 Liberation 字体包名是 `liberation_ttf`（带下划线），原名 `liberation-fonts` 不存在
- **`XDG_DATA_DIRS` 字符串与列表形式冲突 + 重复定义**（`modules/system/fonts.nix` / `modules/desktops/unified-theme.nix`）: NixOS 26.05 的 display-manager 模块把 `XDG_DATA_DIRS` 定义为**列表**，而我们两个模块用的是**冒号分隔字符串**。导致 (1) `either (listOf str) str` 类型检查失败；(2) 字符串定义不支持合并 → "defined multiple times while expected to be unique"。改为列表后，三个模块的 `XDG_DATA_DIRS` 自动拼接
- **`theme-switch` 脚本里整数选项插值未 `toString`**（`modules/desktops/unified-theme.nix`）: `writeScriptBin` 的脚本字符串里 `${startDay}`（int 6）/ `${startNight}`（int 18）直接插值——Nix 不允许 `"${整数}"`，报 `cannot coerce an integer to a string: 6`。trace 挂在 `environment.etc.dbus-1.source` 是因为 dbus 模块的 `serviceDirectories` 会强制求值整个 `environment.systemPackages`，而 `theme-switch` 就在里面。修复：用 `${toString startDay}`。**续坑**：修复注释时在 `''...''` 字符串内写了 `# ... ${startDay} ...`，Nix 对 indented string 里**所有** `${...}` 都插值（包括注释行），又炸了一次。最终用 `''${` 转义注释里的字面量
- **Home Manager 独立 nixpkgs 实例也需 allowUnfree**（`flake.nix`）: 系统级 `nixpkgs.config.allowUnfree = true` 只作用于 NixOS 主配置，HM 有独立的 nixpkgs 实例。在 `mkHost` 里加 `home-manager.sharedModules = [ { nixpkgs.config.allowUnfree = true; } ]` 让 HM 也允许 Steam/Discord 等非自由包
- **`qt.platformTheme = "gtk3"` 枚举值已移除**（`modules/desktops/unified-theme.nix`）: nixos-26.05 只接受 `"gnome"`/`"gtk2"`/`"kde"`/`"lxqt"`/`"qt5ct"`，`"gtk3"` 已删（Qt 6 原生支持 GTK 3 集成）。改为 `"gnome"`，语义等价
- **移除多余的 `services.dbus.enable = true`**（`shell-dms.nix` / `shell-noctalia.nix`）: NixOS 26.05 桌面环境模块会自动拉取 dbus，显式设置属于冗余。注：最初误以为这是 `cannot coerce an integer to a string: 6` 的根因，实际真因是 `theme-switch` 的整数插值（见上），但移除冗余显式启用本身也是对的
- **`environment.etc."skel/.wallpapers".recursive` 已移除（26.05）**: `modules/desktops/unified-theme.nix` 里 `environment.etc.submodule` 默认对目录 source 做递归复制，`.recursive = true` 选项在 26.05 被移除。删掉
- **`home/common/git.nix` 的 git 选项重命名（HM 26.05）**: `userName`/`userEmail`/`extraConfig` 已合并进 `settings.submodule`。改为 `settings.user.name`/`settings.user.email`/`settings.{其余}`
- **`home/common/shell.nix` 的 `programs.zsh.initExtra` 已废弃（HM 26.05）**: 改为 `programs.zsh.initContent`。**注意**：Bash 没改，还是 `initExtra`
- **`steam` 等 unfree 包被拒绝求值**: 加 `nixpkgs.config.allowUnfree = true` 到 `modules/system/default.nix`，允许 Steam、Discord 等非自由软件。之前无限递归导致从没走到包求值阶段，所以一直没暴露
- **`home/common/apps.nix` 中 `wps-office-cn` 不在顶层**: 删掉（NixOS 官方仓库不包含 WPS Office）
- **`home/common/apps.nix` 中 `nemo-extensions` 不在顶层**: 删掉，需要时可通过 Cinnamon/Nemo 模块配置
- **`home/hosts/desktop/default.nix` 中 `kdenlive` 不在顶层**: nixos-26.05 里 kdenlive 不在顶层 pkgs。删掉（需要时可通过 `pkgs.kdePackages.kdenlive` 或指定 Qt 版本）
- **`home/common/dev-lsp.nix` 中 `clangd` 不是独立顶层包**: `clangd` 是 `clang-tools` 包里的二进制，`clang-tools` 已在列表里。删掉重复/不存在的 `clangd`
- **`theme-hyprland.nix` / `theme-niri.nix` 里 config 引用又触发 infinite recursion**: 拆文件时注释写了「放在 config 块内部」但实际根本没包进 `config = { ... }`，而是直接写在模块返回值顶层表达式里，还引用了 `config.wayland.windowManager.hyprland.settings or {}` 来做手动 merge。两个教训：
  1) **attrset 自动合并替代手动 merge**：HM 模块框架会自动合并同名 attrset，不需要先读 config 再用 `lib.mkMerge` 手动拼接。hyprland.nix 写了 `settings = { general = {...}; decoration = {}; }`，theme-hyprland.nix 写 `settings = { general = { col.* = ... }; decoration = { rounding = 12; ... }; }`，框架自动 merge 两个 general 和两个 decoration
  2) **彻底不引用 config**：既然 option 存在由 imports 顺序保证，配置合并由框架自动处理，主题文件完全不需要 config 参数。重写为纯 attrset，0 个 config 引用
- **`pkgs.gnome.gnome-themes-extra` / `pkgs.gnome.adwaita-icon-theme` 已搬到顶层**: nixos-26.05 的 gnome scope 里这两个包已经不存在，直接用顶层 `pkgs.gnome-themes-extra` / `pkgs.adwaita-icon-theme`。涉及 `home/common/theme-gtk.nix`、`modules/desktops/desktop.nix`、`modules/desktops/unified-theme.nix` 共 3 个文件
- **`home/common/editor.nix` Neovim 插件列表里 `nixvim` 和 `nix-syntax-vim` 不存在**: 两个都不在 nixos-26.05 的 `pkgs.vimPlugins` 里。已删除
- **`home/common/editor.nix` Neovim 插件列表里 `autopairs-nvim` 不存在**: nixos-26.05 分支的 `pkgs.vimPlugins` 里根本没有 `windwp/nvim-autopairs`（neovim 0.10+ 有内置配对，可后续按需替代），直接删掉
- **`home/common/editor.nix` Neovim 插件列表里 `lspconfig` 未定义**: `pkgs.vimPlugins` 里没有叫 `lspconfig` 的包，正确名字是 `nvim-lspconfig`（插件列表末尾已存在）。删掉重复/不存在的 `lspconfig`
- **`modules/services/network.nix` 中 `networking.useDHCP` 与 networkmanager 冲突**: NixOS 26.05 的 `networking.networkmanager.enable = true` 会自动把 `networking.useDHCP` 设为 `false`（NetworkManager 自己管理 DHCP），我们手动设了 `useDHCP = true` 就导致冲突定义。删除那行即可
- **`home/common/theme-gtk.nix` 中 `xdg.iconTheme` 选项不存在**: Home Manager release-26.05 的 `xdg` 模块（`modules/misc/xdg.nix`）只有 base directories（`cacheHome`/`configHome`/`dataHome`/`binHome`/`stateHome`）和 session variables 相关选项，**从来没有 `iconTheme`**。图标主题统一由 `gtk.iconTheme` 设置（已配置为 Papirus-Dark）。这个错误选项从 `unified-theme.nix` 原样搬过来，之前一直被 infinite recursion 掩盖没暴露。现删除整个 `xdg.iconTheme` 块

## [v0.0.6] - 2026-11-05
### Fixed
- **`modules/desktops/*.nix` 与 `modules/input-method/default.nix` 中 `lib.mkIf` 放在模块顶层导致 infinite recursion**: 模块顶层的 `lib.mkIf config.desktop.windowManager / shell / enableInputMethod` 被 desktop.nix 的 `imports` 列表求值时触发循环依赖：求值 module function → 解析 mkIf 的 config 条件 → config 是惰性 thunk → 需要合并所有模块 config 才能解析 → 又回到这里。NixOS 报错提示的正是这种模式（*"reference `config` in `imports`"*）。修复：把 `lib.mkIf` 全部挪进 `config = lib.mkIf ... { ... }` 块内部，模块顶层只返回纯 `{ config = ... }` 结构，NixOS modules 框架会在合并 config 之后才求值 mkIf 条件，此时 config 值已确定。涉及 `hyprland.nix`、`niri.nix`、`shell-dms.nix`、`shell-noctalia.nix`、`input-method/default.nix` 共 5 个文件
- **`home/common/unified-theme.nix` 选项不存在时的 unmatched definition + 理论循环风险**: 两次迭代后才收敛到"三层防护"方案：
  1) **层 1（属性存在性）**：`// optionalAttrs (config.wayland.windowManager ? hyprland)` —— 模块顶层用 `?` 只检查 attrset key 存在性（不展开 config thunk 值，安全不循环），HM 模块未加载时整个 option 不拼入返回值，从根源避免 unmatched definition
  2) **层 2（值启用标记）**：option 值内部 `lib.mkIf (config.wayland.windowManager.hyprland.enable or false)` —— 模块已加载但 enable=false 时值为空
  3) **层 3（已有配置兜底）**：`(...settings or {}).decoration or {}` 多级 `or {}` 读已有配置做 merge
  之前两次尝试：(a) 原始代码 `// optionalAttrs (config.xxx && config.xxx.enable)` 在顶层展开 config 值（理论循环风险）；(b) 上次把条件全挪到 option 值内部，但 option 不存在时赋值语句仍发生（`_type = "if"` 导致 unmatched definition）。同时修正 `workspace-strip` 为字符串属性名 `"workspace-strip"`（连字符非合法 Nix 标识符）
- **`home/common/niri.nix` 多余的 `settings.xwayland` 键**: Niri 的 XWayland 支持内建，不需要也不存在 `xwayland` 配置节，整个块已删除
- **`modules/system/default.nix` 中 `/boot/loader/entries` 的 tmpfiles 规则有破坏性**: `tmpfiles.rules = [ "d /boot/loader/entries - - - - 3" ]` 的 age 字段无单位时按秒解析，**每次开机都会删掉系统刚写入的所有引导条目**，轻则引导菜单空、重则无法引导。已删除该 tmpfiles 规则，保留 `boot.loader.systemd-boot.configurationLimit = 3` 让 systemd-boot 自身管理版本数量
- **`wayland.windowManager.hyprland.keybinds` / `binds` 不存在**: Home Manager 的 hyprland 模块没有 `keybinds`、`binds` 选项，报 `The option 'home-manager.users.<user>.wayland.windowManager.hyprland.binds' does not exist`。快捷键与鼠标绑定统一改为 `settings.bind` / `settings.bindm` 列表（Hyprland 原生 `bind` / `bindm` 指令，键位与动作不变）；同时删除 `settings.xwayland.enable`（XWayland 由系统级 `programs.hyprland.xwayland.enable` 控制），`windowrulev2` 条目去掉多余的 `rule = ` 前缀
- **`programs.zsh.prompt` 不存在**: Home Manager 的 zsh 模块没有 `prompt` 选项，报 `The option 'home-manager.users.<user>.programs.zsh.prompt' does not exist`。已删除该行，提示符统一由 `programs.starship.enable` + `enableZshIntegration` 接管
- **`home/common/shell.nix` 别名键名语法错误**: 报 `syntax error, unexpected '.', expecting identifier or 'or' or '${' or '"'`。`cd..`、`..`、`...` 不是合法的 Nix 标识符（`.` 非标识符字符，`...` 是函数参数的省略号记号），改为字符串属性名 `"cd.."` / `".."` / `"..."`；系统级 `environment.shellAliases` 键名经核对无需改动
- **核实 `qt6Packages` 包名（对照 nixos-26.05 官方源码）**: 逐一核对代码中的 `qt6Packages.*` 引用。`qt6-packages.nix` 作用域文件与 `qt6` 核心模块合集中均无 `adwaita-qt`（它只是 by-name 顶层包），因此删除 `modules/desktops/desktop.nix` 的 `qt6Packages.adwaita-qt`，保留已有的 `adwaita-qt`；`qt6Packages.fcitx5-qt`、`qt6Packages.fcitx5-chinese-addons`、`qt6Packages.fcitx5-configtool` 确认存在于该作用域内，保持原样未改动
- **`home/common/unified-theme.nix` 模块返回值顶层表达式引用 config 导致 infinite recursion（最终根因修复）**:
  - 之前用 `? hyprland`（只查 key 不展开值）+ `option 值内部 lib.mkIf` 两层防护，以为已经安全——**实测仍触发循环**
  - **根因重新定位**：NixOS modules 框架在构建 config thunk 时，需要先拿到**所有模块的返回值表达式**（attrset 字面量）才能开始合并；`unified-theme.nix` 的返回值是 `{ gtk = ... } // optionalAttrs (config.wayland.windowManager ? hyprland) { settings = ... }`——框架拿到这个表达式后要对 `//` 求值，右侧的 `optionalAttrs` 需要求值 `config.wayland.windowManager ? hyprland`，而 config thunk 还没构建完（框架正在收集返回值！）→ **循环**
  - 关键认知：**在模块 function 的返回值顶层表达式里（不在 `config = { ... }` 块内），任何对 config 的引用——哪怕是 `? xxx` 这种看似惰性的 attrset key 检查——都可能触发循环**
  - **最终方案：拆文件 + 主机 imports 层面决定**：
    1. `home/common/theme-gtk.nix`（纯 GTK/XDG，不引用 config，无条件导入）
    2. `home/common/theme-hyprland.nix`（Hyprland 配色，config 块内部 `lib.mkIf`，由 desktop.nix 显式导入——此时 hyprland HM 模块已在 imports 里，option 一定存在）
    3. `home/common/theme-niri.nix`（Niri 配色，同上，由 laptop.nix 显式导入）
    4. 删除 `home/common/unified-theme.nix`
    5. 更新 `install.sh` / `install_en.sh` 对应输出

## [v0.0.6] - 2026-11-04
### Fixed
- **flake.nix 顶层 let 语法 + flake evaluator 拒绝 let 包裹顶层 attrset**: 连续两次尝试失败。第一次把 `let ... in { ... }` 写在 attrset 内部作为属性之间的语句，Nix 报 `syntax error, unexpected 'let', expecting 'inherit'`；第二次虽然把 `let ... in` 移到了最顶层，但 flake evaluator 仍然拒绝（它要求 flake.nix **顶层表达式必须是纯 attrset**）。最终修复：顶层回到纯 `{ ... }`，`nixConfig` 直接内联 substituters / trusted-public-keys，`outputs` 的 inner let 里重新定义这两个数组给 specialArgs 消费。文件顶部注明这个 flake evaluator 约束
- **Nix 选项路径错误**: `modules/desktops/unified-theme.nix` 的 SDDM 配置用了 `services.sddm`（NixOS 26.05 中不存在），改为 `services.displayManager.sddm`；同时修正 `config.services.sddm.enable` → `config.services.displayManager.sddm.enable`。此错误会导致 Nix 求值直接失败
- **`nixosConfigurations.<host>` 不存在**: 报错 `flake ... does not provide attribute 'nixosConfigurations.my-hostname'` 的根因是 flake.nix 的 `nixosConfigurations` 为空集合，主机条目只能由 `install.sh` 在仓库根目录运行时写入；`my-hostname` 仅为文档占位符。`install.sh` / `install_en.sh` 新增自动定位：按脚本自身路径（`BASH_SOURCE`）自动 `cd` 到仓库根目录，因此在任意目录下调用都能正确写入主机配置；仓库结构缺失（无 `flake.nix` / `hosts` / `home`）时立即报错退出
- **未启用 flakes 环境下安装失败**: 报 `experimental Nix feature 'nix-command' is disabled`。`install.sh` / `install_en.sh` / `update.sh` / `update_en.sh` 内所有 nix 调用统一走 `NIX=(nix --extra-experimental-features "nix-command flakes")`，不再依赖目标环境的 `nix.conf`；`setup-disk.sh` / `setup-disk_en.sh` 的安装指引补充 `sudo NIX_CONFIG='experimental-features = nix-command flakes' nixos-install --flake .#<host>` 写法；FAQ 新增该报错的三类处理方式
- **`imports` 中的 `lib.mkIf` + 裸路径导致 path 类型定义错误**: 报 `trying to define a value of type 'path' rather than an attribute set for the option ''`。`imports` 元素里的 `(lib.mkIf cond ./x.nix)` 会把路径当作模块定义下发，模块系统无法处理。改为 `imports = [ ... ] ++ lib.optional cond ./x.nix`（`imports` 支持路径项与列表拼接，但不支持嵌套列表）
- **flake `nixConfig` 下发 `auto-optimise-store` 的警告**: 该设置为 restricted setting，客户端会被忽略并输出 `ignoring the client-specified setting 'auto-optimise-store'`。已从 `nixConfig` 移除，统一由 `modules/system/default.nix` 的系统级 `nix.settings` 设置
- **`undefined variable 'config'`**: `modules/desktops/unified-theme.nix` 与 `home/common/unified-theme.nix` 使用了 `config` 但函数参数只声明了 `{ pkgs, lib, ... }`，现补上 `config`；同时删除 `modules/desktops/unified-theme.nix` 顶部未被引用的 `let` 块（`getThemeMode` 脚本与 `lib.mkDefault` 变量）
- **SDDM 不存在选项与过时包名**: 报 `The option 'services.displayManager.sddm.greeterEnvironment' does not exist` 等价问题。26.05 的 `services.displayManager.sddm` 仅有 `enable`/`package`/`theme`/`settings`/`wayland`/`autoLogin` 等 11 个选项，`displayServer` 与 `greeterEnvironment` 均不存在：`sddm.nix` 删除 `displayServer`（由 `wayland.enable` 决定），`unified-theme.nix` 删除整个 greeter 环境变量块。另修正包名：`libappindicator-gtk3`（已从 nixpkgs 移除）→ `libayatana-appindicator`，`networkmanager-applet` → `networkmanagerapplet`（DMS / Noctalia 两个模块）
- **`imports` 被写在 `config` 内导致求值失败**: 报 `The option 'imports' does not exist`，定义来自 `modules/desktops/desktop.nix`。`imports` 是模块级属性而非选项，不能出现在 `config` 块中。现将其提升到顶层，条件逻辑不再放在 `imports` 中（见下一条）；同时把 `environment.systemPackages` 中用 `lib.mkIf` 包裹的 polkit 代理包改为 `lib.optional`（列表元素不能是 `mkIf` 生成的属性集，否则会在包类型校验阶段失败）
- **`i18n.locales` 选项已移除**: 报 `The option 'i18n.locales' does not exist`。NixOS 24.11 起该选项被移除，`modules/system/default.nix` 改用 `i18n.extraLocales = [ "zh_CN.UTF-8" "en_US.UTF-8" ]`（值为 locale 名，不再包含 ` UTF-8` 编码段）
- **`boot.efi` 选项不存在导致求值失败**: 报 `The option 'boot.efi' does not exist`。`modules/boot/default.nix` 误用了 `boot.efi`（NixOS 无此选项）以及 `boot.loader.systemd-boot.efiSysMountPoint`（该选项实际位于 `boot.loader.efi`），现改为 `boot.loader.efi.canTouchEfiVariables` 与 `boot.loader.efi.efiSysMountPoint = "/boot"`，并删除无效的 `boot.efi.enable`
- **新建主机配置未被 Git 跟踪**: 报 `Path 'hosts/<host>/configuration.nix' in the repository "... " is not tracked by Git`。Nix 对 git 仓库中的 flake 只读取已跟踪文件，`install.sh` / `install_en.sh` 新增 `git_track()`，在生成主机配置、`flake.lock`、硬件配置后自动 `git add`，并在 `nix flake check` 前兜底；README 方式三与 FAQ 补充手动 `git add` 步骤
- **统一磁盘布局为 LVM**:
  - `setup-disk.sh` / `setup-disk_en.sh` 磁盘只划分 EFI 与数据两个分区（启用加密时数据分区为 LUKS2 容器），不再为 `/` 与 `/home` 单独分区；`/` 与 swap 统一为 LVM 逻辑卷，`/home` 位于 `/` 下
  - swap 逻辑卷大小随磁盘容量动态调整（取磁盘容量的 10%，限制 2–16 GiB），取代固定 16 GiB
  - 新增逻辑卷存在性校验，`pvcreate`/`lvcreate` 增加 `-y` 以支持重复执行

### Added
- **安装指南网站**: 新增 `hl4w-install/` 目录，包含中英双语独立 HTML 页面（`index.html` / `index_en.html`）。技术安装指南风格，带粘性侧边导航、三方式切换标签、步骤卡片、参数表、FAQ 折叠卡片、TOC 高亮与移动端自适应

### Changed
- **flake.nix 完整审计与注释增强**: 对照 NixOS 26.05 与 Home Manager release-26.05 官方规范完整审计 flake.nix（fetch HM 源码确认 `nixosModules.home-manager` 路径正确）；确认所有 inputs 版本对齐、oh-my-rime 源码输入消费链完整（flake inputs → extraSpecialArgs → home/common/input.nix）、specialArgs 的缓存配置变量被 modules/system/default.nix 实际消费；补充 USERNAME 占位符格式约束、extraSpecialArgs / specialArgs 双重 inputs 传递说明、空 nixosConfigurations 默认值与 mkHost 追加格式注释
- **oh-my-rime 默认改用 CNB 镜像源**: `inputs.oh-my-rime` 默认源由 `github:Mintimate/oh-my-rime/main` 改为 `git+https://cnb.cool/Mintimate/rime/oh-my-rime`（已核实镜像可访问、默认分支同为 `main`），GitHub 上游地址保留为并列注释以便切回；切换源后执行 `nix flake update oh-my-rime` 刷新锁文件条目。README、architecture、faq 同步更新说明
- **移除 GitHub Actions CI**: 删除 `.github/workflows/build.yml`（仓库当前不需要远端构建）；同步删除 architecture.md / architecture_en.md 的「持续集成」小节、README 目录树与文档索引中的 CI 提及

### Documentation
- **FAQ 重写**: 新增「重建 flake.lock」「添加自定义字体」「切换 Catppuccin flavor」「DMS Shell / Noctalia Shell 配置」等实用新问题；将之前分散的 5 个 CLI 工具单节（dust、duf、tokei、hyperfine、procs）合并为一张速查表；补充 install.sh 非交互模式参数说明；桌面 Shell 小节明确标注 `desktop.shell` 选项位置与模块名；壁纸颜色不生效新增完整排查清单；故障排除补充更多 NixOS 26.05 特有问题（如 kdePackages/qt6Packages 包名）
- **shortcuts 文档与实际配置对齐**: Hyprland 快捷键表改为物理键名（`Super + F11` 对应 Hyprland 内部键名 `FULL`）；浮动窗口规则明确 `class` 匹配；新增配置摘要（master 布局、gaps、动画、XWayland）；鼠标绑定表补充侧键透传说明；Niri 补充 workspace-strip 在顶部；整体新增"本文档与配置文件一一对应"声明与 `home-manager switch` 应用提示
- **梳理三种安装路径与脚本调用链**: README 方式一去除冗余的预先 clone 步骤（`setup-disk.sh` 内部会把仓库克隆到 `/mnt/etc/nixos` 并自行调用 `install.sh`），改为「ISO 直接下载 setup-disk.sh 执行 + cd 到 `/mnt/etc/nixos` 执行 `nixos-install`」；方式二补充完整的后续步骤（`nix flake update` 首次运行、`nix flake lock`/`nixos-generate-config --root /` 自动生成、`nixos-rebuild switch --flake .#<hostname>`、`home-manager switch`）；`setup-disk.sh`/`setup-disk_en.sh` 末尾提示明确标注仓库位置 `/mnt/etc/nixos`，避免用户在错误目录下执行 `nixos-install`
- **docs 全量同步磁盘布局与调用链**: `glossary.md` 逻辑卷条目更新为 `root`/`swap` 并说明 `/home` 位于 `/` 下；`migration.md` 硬件配置检查说明改为「根逻辑卷 `/dev/vg/root` / 交换逻辑卷 `/dev/vg/swap` / EFI 启动分区」；`architecture.md` 与 `faq.md` 初始安装示例补充 setup-disk.sh 内部自动 clone 到 `/mnt/etc/nixos`、调用 install.sh 完成主机配置与硬件生成的完整链路，ISO 场景不再要求预先 clone

## [v0.0.6] - 2026-11-02
### Fixed
- **脚本健壮性修复（`scripts/` 全部 14 个脚本）**:
  - `setup-disk.sh` / `setup-disk_en.sh` 重写：修正非加密路径 p3 与 p2 重叠、`mkswap` 在根分区挂载前执行、`/dev/sda` 分区名推导错误（改用 `part_name()` 函数）、重复 `mkfs`；加密流程增加密码二次确认；改用数组传参替代 `eval`
  - `setup-disk.sh` / `setup-disk_en.sh` 新增交互式选择：未传 `-T/-W/-S` 时在交互终端提示选择主机类型/窗口管理器/桌面 Shell（回车用默认值）；`-y` 或 stdin 非终端时回退默认 `desktop`/`hyprland`/`dms`；同时校验显式传入的取值，非法值直接报错
  - `clean.sh` / `clean_en.sh`：修复 `-s`/`-g` 参数互相清零导致「两个都不清理」的问题；`nix store gc` 改由 `sudo` 执行（store 属 root）
  - `update.sh` / `update_en.sh`：主机名自动回退；`-H` 缺少参数时报错；构建改用完整属性路径 `nixosConfigurations.<host>.config.system.build.toplevel`
  - `setup-direnv.sh` / `setup-direnv_en.sh`：改用 `nix profile install nixpkgs#direnv`（`nix-env -iA nixos.*` 在 flakes 环境不可用）；`.envrc` 不存在时跳过 `direnv allow`；写入 hook 前创建目录与文件
  - `wallpaper-color.sh` / `wallpaper-color_en.sh`：`find` 参数改为数组（原字符串拼接导致通配符永不匹配）；修正 `local name=$(...)` 变量声明；`wal -R` 失败不再中断；hyprpaper 应用壁纸改为全显示器写法，删除未经验证的 `noctalia-shell`/`dms-shell` 命令行参数；`-h` 不再要求 pywal
  - `wallpaper-watcher.sh` / `wallpaper-watcher_en.sh`：初始化 `LAST_CACHE_MODIFIED`（原未初始化导致数值比较报错）；pywal 壁纸路径直接读取 `~/.cache/wal/wal`；取色失败不再退出监听进程；检查间隔可通过 `WATCH_INTERVAL` 配置
  - `install.sh` / `install_en.sh`：`youruser` 占位符替换加入 sed 转义与替换后校验；`POWER_MANAGEMENT` 显式初始化；非交互模式（`-y`）缺失必需参数时直接报错而非阻塞提问；新增主机类型/窗口管理器/桌面 Shell/polkit 代理取值校验；`nixos-generate-config` 在安装介质下自动追加 `--root /mnt`；移除 Intel `i915.enable_psr=0` 内核参数；构建提示改用完整属性路径
- **修复 NixOS 与 Home Manager 模块边界混淆（致命级）**:
  - `wayland.windowManager.hyprland` / `wayland.windowManager.niri` 是 Home Manager 模块，在 NixOS 系统层不存在 → 重构：NixOS 层用 `programs.hyprland`/`programs.niri` 负责安装，详细配置移至 `home/common/hyprland.nix`/`niri.nix`
  - `gtk.*` / `xdg.iconTheme` 是 Home Manager 选项 → 从 `modules/desktops/unified-theme.nix` 移至 `home/common/unified-theme.nix`，系统层仅保留 `qt`/`services.displayManager.sddm`/`environment.*`
  - NixOS `qt` 模块仅支持 `enable`/`platformTheme`/`style`，移除不存在的 `qt.iconTheme`/`qt.font`
- **移除不存在的 NixOS 选项（致命级）**:
  - 删除 `security.pam.enableSSS = false` — NixOS 中不存在此选项
  - 删除 `security.faillock.enable = true` — NixOS 中不存在此选项
  - 删除 `programs.noctalia-shell.enable` / `programs.dms-shell.enable` — 是 Wayland shell 包，非模块选项
- **修复 Nix 语法错误（致命级）**:
  - `services.display-manager` → `services.displayManager`（连字符非合法 Nix 标识符，会被解析为减法）
  - `services.sddm` → `services.displayManager.sddm`（`services.sddm` 在 NixOS 中不存在，会导致求值失败）
- **修复 Hyprland 0.55 (NixOS 26.05) 兼容性**:
  - 移除 `hyprnix` flake input，使用 NixOS 原生模块
  - 添加 `configType = "hyprlang"`（0.55+ 默认 Lua）
  - `misc.xwayland = true` → `xwayland.enable = true`
  - 移除已废弃的 `hyprland-plugins.*` 和独立 `xwayland` 包
  - `kb_layout = "us,cn"` → `"us"`（"cn" 非有效 XKB 布局，中文由 fcitx5 处理）
- **适配 Home Manager 26.05**:
  - 添加 `home.stateVersion = "26.05"`（HM 26.05 起无默认值，必须显式设置）
  - `gtk.gtk4.theme` 不再默认镜像 `gtk.theme`，显式设置 `Adwaita-dark`
  - 修正 `gtk.theme.package`：`adwaita-icon-theme`（图标包）→ `gnome-themes-extra`（Adwaita 主题包）
- **修复弃用/移除的包名**:
  - `noto-fonts-cjk` → `noto-fonts-cjk-sans` + `noto-fonts-cjk-serif`
  - 移除已不存在的 `noto-fonts-emoji`（保留 `noto-fonts-color-emoji`）
- **修复 Home Manager 选项位置错误**:
  - `programs.yazi.shell.enableZoxideIntegration` → `programs.yazi.settings.shell.enableZoxideIntegration`（HM yazi 模块无顶级 shell 选项）
- **修复 install.sh 生成的 Home Manager 配置**:
  - 添加 `unified-theme.nix` 和对应 WM 模块（`hyprland.nix`/`niri.nix`）的导入
- **修复 Fcitx5 与 oh-my-rime 冲突**:
  - 移除系统级 `rime-data-*` 包
- **修复 wallpaper-watcher.nix 无效选项**:
  - 移除 `systemd.user.enable = true`（`Install.WantedBy` 已自动处理）
- **清理无效配置**:
  - 移除 `allowedUDPPorts = [ 80 443 ]`（HTTP/HTTPS 仅 TCP）
  - 移除独立 `nvidia-settings`（已包含在驱动中）
- **修复字体包引用导致构建失败**:
  - `fonts.nix` 的 `XDG_DATA_DIRS` 仍引用已被拆分的 `pkgs.noto-fonts-cjk` → 改为 `noto-fonts-cjk-sans` + `noto-fonts-cjk-serif`
- **修复 CI 与构建脚本**:
  - `.github/workflows/build.yml` 监听分支 `main` → `master`（与实际分支一致，否则 CI 永不触发）
  - `.github/workflows/build.yml` 构建目标 `nix build .#desktop`/`.#laptop`/`.#server`（不存在的 flake 输出）→ 先用 `nix flake check --no-build` 做求值检查，再动态发现 `nixosConfigurations` 并构建完整属性路径 `nixosConfigurations.<host>.config.system.build.toplevel`；未声明主机时仅告警并跳过构建
  - `.github/workflows/build.yml` 重写为单 job 流程：新增 `concurrency` 以取消同分支重复运行，主机列表通过 `env` 传递避免直接拼接进 shell，构建前统一执行求值检查
  - `.github/workflows/build.yml` 移除单独的 `nix flake lock` 步骤（建议将 `flake.lock` 提交到仓库以固定依赖版本），并启用 `auto-allocate-uids` 实验特性
  - `Makefile` 的 `switch-home` 硬编码占位符 `youruser@desktop` → 改为 `USER`/`HOST` 变量，支持 `make USER=<name> HOST=<host>`
  - `Makefile` 的 `build` 目标 `nix build .#$(HOST)`（不存在的 flake 输出）→ `nix build .#nixosConfigurations.$(HOST).config.system.build.toplevel`
- **移除系统层重复的主题环境变量**:
  - 删除 `GTK_THEME`/`GTK2_RC_FILES`/`QT_STYLE_OVERRIDE`/`XDG_ICON_THEME`（优先级高于 Home Manager 用户级配置，会覆盖 `gtk`/`xdg.iconTheme` 模块）
- **修复桌面 Shell 模块**:
  - `shell-dms.nix` 改用 NixOS 26.05 官方 `programs.dms-shell` 模块（自带依赖与 `dms.service` systemd 启动），不再裸装 `dms-shell` 包
  - `shell-noctalia.nix` 移除 26.05 已删除的 `blueberry` 包；`services.power-management.enable`（不存在）→ `powerManagement.enable`；补充 `services.upower.enable`；精简 `noctalia-shell` 包内已包装的运行时依赖

### Changed
- **明确 Shell 命名现状**: nixos-26.05 中 `dms-shell`/`noctalia-shell` 均未改名；上游 `dux-shell`（DMS 2.0）与 `noctalia` v5 属新包，26.05 稳定分支未回移，故保持现有命名
- **架构重构**: 窗口管理器详细配置从 NixOS 系统层移至 Home Manager 用户层，符合 NixOS 原生模块边界
- **简化 flake.nix**: 移除 `hyprnix` flake input
- **统一用户组声明**: `video`/`audio`/`docker` 组统一在 `hosts/common/default.nix` 中声明
- **统一终端浮动规则**: Hyprland windowrulev2 添加 `foot` 终端浮动规则
- **更新架构文档**: `architecture.md` 和 `architecture_en.md` 同步反映模块边界重构

### Documentation
- **新增术语对照表**: `docs/glossary.md` 与 `docs/glossary_en.md` 定义规范术语、代码标识符与书写规则
- **统一文档术语**: README、架构、FAQ、迁移与快捷键文档统一使用 `DMS Shell` / `Noctalia Shell`、`Home Manager`、`系统代`、`flake 配置名称` 等表述；`CHANGELOG` 保留历史表述不做回改
- **同步文档内容**: 架构文档更新 flake 输入（oh-my-rime 替代 hyprnix）与字体包名（`noto-fonts-cjk-sans`/`serif`），补充 glossary 文档索引与 `pkgs.lix` 写法；FAQ 与迁移文档补充 `setup-disk.sh` 安装路径、`nix flake update` 前置步骤、`nixosConfigurations` 完整构建属性路径及 `clean.sh` 参数；壁纸命令统一为 `wp-color -s/-d/-a/-l/-c`（删除不存在的 `wp-apply`/`wp-list`，修正 `wp-color -s` 无参数用法）；SDDM 选项路径修正为 `services.displayManager.sddm`；`powerManagement.cpuFreqGovernor` 去掉错误的 `services` 前缀；快捷键文档修正 Hyprland/Niri 配置位置为 `home/common/`，补充浮动规则（含 Foot）与键盘布局说明
- **文档示例通用化**: README、架构与 FAQ 中的 `setup-disk.sh` 示例改用 `<disk>`/`<hostname>`/`<username>` 占位符，并说明 `-T/-W/-S` 省略时交互选择、`-c` 关闭加密的用法
- **README 重排**: 特性按「桌面与外观 / 安装与系统 / 中文与办公 / 终端与开发」分组，新增「部署前验证」与「日常管理」小节，统一术语与完整属性路径说明并去除重复段落，中英文版结构保持一致
- **补充交互选择与 CI 说明**: README 与架构文档说明 `setup-disk.sh` 省略 `-T/-W/-S` 时的交互式选择与 `-y`/非终端回退规则；架构文档新增「持续集成」小节，说明 `build.yml` 的 `nix flake check --no-build`、动态主机发现与完整构建属性路径，并提示提交 `flake.lock`

## [v0.0.5] - 2026-06-16
### Added
- **GPL v3.0 许可证更新**: 验证并确认项目使用完整的 GNU General Public License v3.0
- **文档版本统一**: 更新所有文档文件版本号为 v0.0.5
  - `flake.nix` - Flake 入口文件版本更新
  - `docs/architecture.md` - 架构文档版本更新
  - `docs/architecture_en.md` - 架构文档（英文）版本更新
- **作者信息**: 在 README 文档和所有脚本文件中添加作者信息 "Author: Silas Zhang (2026)"
- **Bash Shell 支持**: 添加完整的 Bash 配置支持
  - 系统级安装和启用 Bash (`modules/system/default.nix`)
  - 用户级 Bash 配置 (`home/common/shell.nix`)
  - Starship 提示符集成 Bash
  - Bash 和 Zsh 共享相同的环境变量和别名配置
- **仓库名称更新**: 将仓库名称从 `nixfiles26` 改为 `nixfiles`
- **仓库 URL 更新**: 添加 Gitee 和 GitHub 双仓库地址
  - 国内用户: `https://gitee.com/hl4w/nixfiles.git`
  - 国外用户: `https://github.com/hl4w/nixfiles.git`
- **快捷键文档**: 创建 Hyprland/Niri 快捷键参考文档
  - `docs/shortcuts.md` - 中文快捷键文档
  - `docs/shortcuts_en.md` - 英文快捷键文档
- **Firefox 快捷键**: 添加 `Super+B` 打开 Firefox 浏览器
- **统一应用程序快捷键**: 统一 Hyprland 和 Niri 的应用程序快捷键配置
  - `Super+R` - 应用启动器 (Rofi)
  - `Super+Return` - 终端 (Foot)
  - `Super+E` - 文件管理器 (Nemo)
  - `Super+B` - Firefox 浏览器
  - `Super+Q` - 关闭窗口
  - `Super+C` - VSCodium
  - `Super+P` - 电源菜单 (Rofi)
  - `Super+Shift+Q` - 退出窗口管理器
- **VSCodium 支持**: 添加 VSCodium（开源版 VS Code）作为默认编辑器
  - 用户级安装 `vscodium` 包 (`home/common/apps.nix`)
  - 快捷键 `Super+C` 打开 VSCodium
- **脚本 Shebang 更新**: 将所有 sh 脚本的 shebang 从 `#!/bin/sh` 更新为 `#!/usr/bin/env bash`，确保 bash 语法正确执行
### Changed
- **许可证验证**: 确认 LICENSE 文件内容符合 GNU GPL v3.0 标准文本
- **图片查看器替换**: 将 `home/common/apps.nix` 中的 `eog`（Eye of GNOME，GTK3）替换为 `loupe`（GNOME 官方继任者，GTK4/LibAdwaita，Wayland 原生），与 evince/nemo 风格统一，支持 HEIF/AVIF/JPEG XL；同步更新 architecture、faq、migration 中英文档
- **NetworkManager 工具优化（NixOS 26.05）**：
  - 将 VPN 插件从 `home/hosts/laptop/default.nix`（用户级 `home.packages`）移至 `hosts/laptop/configuration.nix` 的 `networking.networkmanager.plugins`，因为 NM 守护进程以 root 运行，只能加载系统级插件
  - 新增 `networkmanager-openvpn`（最常见的 VPN 协议）
  - 启用 `networking.networkmanager.wifi.powersave = true`（笔记本 WiFi 省电，NixOS 官方推荐）
  - 确认 `nmcli`/`nmtui` 随 `networking.networkmanager.enable = true` 自动安装，无需单独声明
- **oh-my-rime 输入法配置框架重构**：将 oh-my-rime 从 `home.packages`（非 nixpkgs 包，会导致求值错误）改为 flake input（`github:Mintimate/oh-my-rime/main`），通过 `home.file` 将 schema/dict/lua 文件符号链接部署到 `~/.local/share/fcitx5/rime/`；用 `default.custom.yaml` 覆盖 `schema_list` 指定启用方案，让 RIME 自动生成可写的 `installation.yaml`
- **新增 Fcitx5 Catppuccin 主题**：在 `modules/input-method/default.nix` 的 `fcitx5.addons` 中添加 `catppuccin-fcitx5` 包，通过 `home.file` 写 `~/.config/fcitx5/conf/classicui.conf` 设置 `Theme=catppuccin-mocha-mauve`；支持 4 种 flavor（latte/frappe/macchiato/mocha）× 14 种 accent 配色
### Fixed
- **修复 install.sh 中 FLAKE_NAME 未加引号导致 nix 语法错误**：`scripts/install.sh` 与 `scripts/install_en.sh` 在向 `flake.nix` 的 `nixosConfigurations` 块插入主机条目时，生成的属性名未用双引号包裹（如 `my-desktop-config = mkHost "my-desktop";`）。Nix 会将含连字符的裸属性名解析为减法运算（`my - desktop - config`），导致 `nix flake check` 与 `nixos-rebuild` 失败。现已改为 `"${FLAKE_NAME}" = mkHost "${HOSTNAME}";`
- **修复 install.sh 中 sed 替换的脆弱性**：
  - 新增 `sed_escape_replacement()` 辅助函数，转义替换字符串中的 `\`、`&`、`/`，避免用户名/邮箱/主机名含元字符时破坏 sed 替换
  - Git 用户名、邮箱、flake.nix 用户名的 sed 替换改为精确字段匹配（如 `userName = "Your Name"`），并增加占位符存在性检查，实现幂等运行：重复执行时不再静默无操作，而是输出 `warn` 提示
  - 将 `sed_escape_replacement()` 定义前移至 helper 函数区，避免其在首次使用处之后才定义
- **修复 install.sh 中 flake.nix 主机条目插入逻辑**：
  - 用 `awk index()` 精确匹配 `nixosConfigurations = {` 行后插入，替代转义复杂、跨 sed 版本行为不一致的 `a \\...\\\n` 写法
  - `grep` 检测改为 `grep -qF` 固定字符串匹配，消除 4 空格 vs 6 空格的缩进不一致问题
  - 新增插入后验证步骤：插入失败时立即 `error` 终止，而非静默继续
- **修复 network.nix 中 NetworkManager DNS 选项路径错误**：`services.networkmanager.dns` 在 NixOS 中不存在，实际选项路径为 `networking.networkmanager.dns`，导致 DNS 管理设置未生效。已修正为 `networking.networkmanager.dns = "systemd-resolved"`
- **修复 input.nix 中 oh-my-rime 无法拉取及配置错误**：
  - `home.packages = [ oh-my-rime ]`：oh-my-rime 不是 nixpkgs 包，导致 Nix 求值错误
  - `fetchFromGitHub { owner = "lotem"; rev = "master"; sha256 = fakeSha256 }`：仓库实际为 `Mintimate/oh-my-rime`，默认分支为 `main`，且 `fakeSha256` 为开发占位符无法构建
  - `installation.yaml` 中 `schema_list` 引用的 `luna_pinyin_simp`、`flypy`、`bopomofo` 在 oh-my-rime 仓库中不存在（实际方案为 `rime_mint`、`rime_mint_flypy` 等）
  - `__patch` 引用的 `default.custom.yaml`、`luna_pinyin.custom.yaml`、`key_bindings.custom.yaml` 等文件在 oh-my-rime 仓库中不存在
  - 配置文件通过 `xdg.configFile."rime/..."` 写入 `~/.config/rime/`，但 fcitx5-rime 实际数据目录为 `~/.local/share/fcitx5/rime/`
## [v0.0.4] - 2026-06-15

### Added

- **脚本标准化**: 统一所有 shell 脚本的结构和风格
  - 添加一致的颜色变量 (RED, GREEN, YELLOW, NC)
  - 标准化日志函数 (`info()`, `warn()`, `error()`)
  - 添加 `confirm()` 函数支持非交互式模式
  - 添加 `usage()` 函数显示帮助信息
  - 为所有脚本添加 HL4W 品牌标识
- **update.sh 增强**: 添加主机名参数支持，可指定目标主机进行构建
- **setup-direnv.sh 增强**: 添加自动 Shell 类型检测，支持 bash/zsh/fish
- **脚本中英文同步**: 确保所有中英文脚本版本功能完全一致

### Changed

- **install.sh/install_en.sh 同步**: 更新英文版本以匹配中文版本的所有改进（主机备份、flake 验证、更新命令说明）
- **clean.sh/clean_en.sh 优化**: 更新 confirm 函数支持非交互式模式

## [v0.0.3] - 2026-06-15

### Added

- **完善 CLI 工具集**: 新增更多现代化命令行工具
  - `yazi` - 快速终端文件管理器（用 Rust 编写）
  - `dust` - 磁盘使用分析工具
  - `duf` - 磁盘空间查看工具
  - `tokei` - 代码统计工具
  - `hyperfine` - 命令性能测试工具
  - `procs` - 增强版 ps 命令
  - `zoxide` - 智能目录导航工具
- **Yazi 配置集成**: 在 `home/common/cli.nix` 中配置 Yazi 文件管理器，支持 zoxide 集成
- **Zoxide 导航**: 在 `home/common/cli.nix` 中启用 Zoxide 智能目录跳转
- **壁纸仓库说明**: 在 `wallpapers/README.md` 中添加完整壁纸集合的下载地址 `https://github.com/hl4w/wallpaper.git`
- **项目版本统一更新**: 更新所有文档文件中的版本号为 v0.0.3

### Changed

- **CLI 工具模块化**: 将 CLI 工具从 `apps.nix` 分离到独立的 `home/common/cli.nix` 模块，结构更清晰
- **shell.nix 精简**: 移除与 CLI 模块重复的配置，保持职责分离
- **文档内容更新**: 更新 README、架构文档、FAQ、迁移指南，反映最新的项目状态
- **壁纸 README 更新**: 更新 `wallpapers/README.md` 中的文件列表，仅保留实际存在的 `default.jpg`

### Fixed

- **修复 Lix 配置**: 修正 `modules/system/default.nix` 中 Lix 的引用方式，使用 `pkgs.lix` 替代 `pkgs.lixPackageSets.stable.lix`
- **修复目录结构文档**: 更新架构文档中的目录树，确保与实际文件结构一致
- **修复壁纸 README**: 修正默认壁纸文件名从 `default.png` 为 `default.jpg`

## [v0.0.2] - 2026-06-14

### Added

- **GPU 自动检测**：在 install.sh 中添加 lspci 硬件检测功能
  - 支持 NVIDIA 显卡：自动添加 `modules/hardware/nvidia.nix` 导入和内核参数
  - 支持 AMD/ATI 显卡：自动添加 `amdgpu.si_support=1` 和 `amdgpu.cik_support=1` 内核参数
  - 支持 Intel 集成显卡：自动添加 `i915.enable_psr=0` 内核参数
  - 未知显卡使用通用配置
- **英文版本支持**：为所有脚本创建英文版本
  - `scripts/install_en.sh` - 安装脚本英文版本
  - `scripts/wallpaper-watcher_en.sh` - 壁纸监听器英文版本
  - `scripts/wallpaper-color_en.sh` - 壁纸配色脚本英文版本
  - `scripts/setup-disk_en.sh` - 磁盘设置脚本英文版本
  - `scripts/clean_en.sh` - 清理脚本英文版本
  - `scripts/update_en.sh` - 更新脚本英文版本
  - `scripts/setup-direnv_en.sh` - direnv 设置脚本英文版本
- **英文文档**：创建英文版本的项目文档
  - `README_en.md` - 项目说明文档（英文）
  - `docs/CHANGELOG_EN.md` - 变更日志（英文）
  - `docs/architecture_en.md` - 架构说明（英文）
  - `docs/faq_en.md` - 常见问题（英文）
  - `docs/migration_en.md` - 迁移指南（英文）
- **开发语言 LSP 支持**：为 Go、Python、Rust、C/C++ 添加完整的语言支持（用户级配置）
  - **C/C++**: clangd、clang-tools、cmake、ninja、gdb、lldb
  - **Go**: go、gopls
  - **Python**: python3、pyright
  - **Rust**: rustc、rust-analyzer、rustfmt、cargo
- **Neovim LSP 配置**：为所有支持的语言配置了 LSP 服务器（nil_ls、clangd、gopls、pyright、rust_analyzer）

### Changed

- **NixOS 24.11+ 显卡配置更新**：将 `hardware.opengl` 替换为 `hardware.graphics`
  - `hardware-common.nix` 使用 `hardware.graphics.enable = true`
  - install.sh 安装时自动生成 GPU 通用配置
  - 简化 OpenGL 配置（`driSupport` 等选项已自动启用）
- **音频配置模块化**：将音频配置统一到 `modules/hardware/sound.nix`
  - 包含 rtkit（实时音频服务）、PipeWire（现代音频服务器）、PulseAudio 兼容性
  - `hardware-common.nix` 简化，仅保留注释引用
- **桌面配置优化**：重构 `desktop-common.nix`，分离默认值与主机特定配置
  - `modules/desktops/desktop.nix` 提供桌面选项默认值
  - `hosts/common/desktop-common.nix` 仅包含通用配置（用户组等）
  - install.sh 根据用户选择生成主机级别配置
- **文档结构优化**：将 changelog 移动到 `docs/` 目录
  - `CHANGELOG.md` → `docs/CHANGELOG.md`
  - `CHANGELOG_EN.md` → `docs/CHANGELOG_EN.md`
- **统一文档命名规范**：将英文文档命名从 `.en.md` 改为 `_en.md`
  - `README.en.md` → `README_en.md`
  - `docs/architecture.en.md` → `docs/architecture_en.md`
  - `docs/faq.en.md` → `docs/faq_en.md`
  - `docs/migration.en.md` → `docs/migration_en.md`
- **更新 README**：修复文档链接引用，从 `.zh.md` 改为 `.md`
- **更新架构文档**：完善目录结构树，添加所有实际文件：
  - `modules/boot/plymouth.nix` - Plymouth 启动动画配置
  - `modules/hardware/firmware.nix` - 额外固件支持
  - `modules/hardware/nvidia.nix` - NVIDIA 显卡驱动配置
  - `modules/hardware/sound.nix` - 音频系统配置
  - `home/common/wallpaper-watcher.nix` - 壁纸监听器用户服务
  - `secrets/example.age` 和 `secrets/README.md`
  - `wallpapers/` 目录下所有壁纸文件
- **更新项目版本号**：`flake.nix`、`README.md`、`README_en.md` 均更新为 v0.0.2
- **NixOS 26.05 兼容性优化**：更新 `breeze-icons` 包引用方式，从 `pkgs.breeze-icons` 改为 `pkgs.kdePackages.breeze-icons`，确保 KDE 包版本兼容性
- **现代化系统工具**：移除 `htop`，添加 `btop`（更现代化的系统监控）和 `fastfetch`（快速系统信息展示）到用户级配置
- **扩展字体支持**：添加 `noto-fonts-color-emoji`、`fira-code`、`source-code-pro`、`iosevka`、`font-awesome` 字体包
- **添加拼写检查器**：系统级安装 `nuspell` 引擎（比 Hunspell 快 3 倍）和英语词典（`hunspellDicts.en-us`、`hunspellDicts.en-gb-ise`）。注意：Nuspell/Hunspell 不支持中文拼写检查
- **优化 boot 配置**：
  - 移除显式的 `boot.initrd.systemd.enable`（NixOS 26.05 默认启用）
  - 添加静默启动内核参数：`quiet`、`splash`、`rd.udev.log_level=3`、`rd.systemd.show_status=auto`
  - 设置 `boot.consoleLogLevel = 3` 和 `boot.initrd.verbose = false` 减少启动日志
  - 合并 `loader.efi` 和 `loader.systemd-boot` 配置
  - 显式禁用其他引导加载器（grub、generic-extlinux-compatible）
- **使用 Lix 高性能 Nix**：将 `nix.package` 从默认的 Nix 替换为 `pkgs.lixPackageSets.stable.lix`，使用 overlay 确保依赖 Nix 的工具也使用 Lix，提升 eval 和 fetch 性能
- **Niri 使用官方库**：从 flake 输入移除 `niri`，改用 NixOS 26.05 官方库中的 `pkgs.niri`
  - 移除 `flake.nix` 中的 `niri.url = "github:YaLTeR/niri/main"`
  - 更新 `modules/desktops/niri.nix` 使用 `pkgs.niri` 而不是 `inputs.niri.packages.x86_64-linux.niri`

## [v0.0.1] - 2026-06-11

### Added

- **统一主题配置模块** (`unified-theme.nix`)
  - GTK、Qt、Hyprland、Niri、Noctalia-Shell、DMS-Shell、SDDM 共享相同的配色和图标风格
  - 主题：Adwaita-dark（深色模式）/ Adwaita（浅色模式）
  - 图标：Papirus-Dark / Papirus
  - 字体：Noto Sans CJK SC 11pt（支持中文）
  - 窗口边框：活动窗口绿色（rgba(34, 197, 94)），非活动窗口灰色（rgba(71, 85, 105)）
- **壁纸自动取色配色系统**（pywal）
  - 支持从壁纸提取颜色自动应用到终端、Shell、编辑器
  - 创建 `scripts/wallpaper-color.sh` 脚本
  - 命令别名：`wp-color`、`wp-random`、`wp-apply`、`wp-list`
- **日夜主题自动切换功能**
  - 支持根据时间自动切换深浅主题风格（6:00-18:00为白天）
  - 提供命令行工具：`theme-auto`、`theme-dark`、`theme-light`
  - 可配置日夜切换时间
- **终端模拟器**：添加 kitty 和 foot 终端（与 alacritty 并列）
- **用户级 C/C++ 语言支持**：clangd、clang-tools、cmake、ninja、gdb、lldb
- **优化 `host-template/configuration.nix`**：添加可选模块注释，使其更有效
- **Nextcloud 客户端**：在用户级添加 `nextcloud-client` 包，支持云端文件同步
- **整合 Nemo 相关包到用户级**：nemo、nemo-extensions、evince、eog 统一在 `home/common/apps.nix` 中管理
- **默认终端改为 foot**：将 Hyprland 和 Niri 的默认终端从 kitty 改为 foot（轻量级高性能终端）
- **桌面环境标识动态切换**：`unified-theme.nix` 支持根据窗口管理器自动设置 `XDG_CURRENT_DESKTOP` 环境变量
- **重构主机特定软件包配置**：将桌面/笔记本特定软件包从 `install.sh` 迁移到独立的用户级配置文件
- **分离系统级和用户级配置**：`/hosts/` 目录仅包含系统级配置，`/home/hosts/` 目录包含用户级配置，职责清晰
- **桌面配置模块** (`modules/desktops/desktop.nix`)：支持动态选择窗口管理器（hyprland/niri）、桌面 shell（dms/noctalia）和 polkit 代理（kde/hyprland），无需修改 imports
- **鼠标侧键支持**：在 Hyprland 中添加 `pass` 绑定（Button 8/9），让应用程序（如 Nemo、Firefox）能够正确处理后退/前进功能
- **更新 Qt 相关包名**：适配 NixOS 26.05 包库（`adwaita-qt` → `qt6Packages.adwaita-qt`，`qt6-multimedia` → `qt6Packages.qtmultimedia`，`fcitx5-qt` → `qt6Packages.fcitx5-qt`，`qtwayland` → `qt6Packages.qtwayland`）

### Changed

- 将 `display-manager.nix` 重命名为 `sddm.nix`，便于未来扩展其他显示管理器（如 LightDM、GDM）
- 移除 fcitx5 的 X11 支持，仅保留 Wayland 支持
- 将 `input-method.nix` 从 `hardware/` 目录移动到 `modules/` 根目录
- 移除 podman，只保留 docker（桌面端使用）
- 将 Thunar 替换为 Nemo（支持 PDF/图片预览）
- 将 Wofi 替换为 Rofi（更好的 Wayland 支持）
- 将 Exa 替换为 Eza（exa 已弃用）
- 将 LibreOffice 替换为 WPS Office CN（中国版，中文支持更好）
- **优化字体配置**
  - 创建独立的 `modules/system/fonts.nix` 模块，分离字体配置与主题配置
  - 默认字体使用英文（Noto Sans），通过 FontConfig fallback 支持中文
  - 添加 WPS Office CN 字体别名映射（宋体、黑体、微软雅黑等）
  - 安装完整中文字体：Noto CJK、思源系列、文泉驿系列
- 移除 Waybar，使用窗口管理器自带状态栏
- **优化模块结构，移除重复的包安装**
  - 合并 `unified-theme.nix` 中重复的 `environment.systemPackages` 块
  - 清理 `hyprland.nix`、`niri.nix` 中与用户级重复的包
  - 删除冗余的 `wallpaper-color.nix` 文件（内容已合并）
- **重构项目结构，按功能分类组织模块**
  - 创建 `modules/system/` 目录，存放系统基础配置
  - 创建 `modules/services/` 目录，存放网络、安全、虚拟化服务配置
  - 创建 `modules/input-method/` 目录，存放输入法配置
  - 使用 `default.nix` 作为模块入口，简化导入路径
- **改进辅助脚本功能**
  - `scripts/clean.sh`: 添加命令行参数支持，支持单独清理 store 或旧版本
  - `scripts/update.sh`: 添加根据主机名自动选择构建配置的功能
  - `scripts/setup-disk.sh`: 添加完整的命令行参数支持，支持可选加密、自定义仓库 URL、传递主机类型/窗口管理器/桌面 Shell 参数
  - `scripts/wallpaper-color.sh`: 改进 bash 检测逻辑，支持项目壁纸目录和用户壁纸目录，添加颜色输出日志函数，支持更多壁纸格式（jpg、jpeg、png、gif、webp）
- **添加壁纸文件夹**
  - 创建 `wallpapers/` 目录用于存放壁纸文件
  - 默认壁纸为中国风雄伟山河深色调（`default.jpg`）
  - 更新 `home/common/shell.nix`，自动复制壁纸目录到用户目录
  - 更新 `modules/desktops/unified-theme.nix`，添加壁纸目录自动创建支持
  - 更新 `scripts/wallpaper-color.sh`，支持从项目目录读取壁纸，添加对 Noctalia-Shell 和 DMS-Shell 的壁纸设置和配色支持
- **添加壁纸变化监听服务**
  - 创建 `scripts/wallpaper-watcher.sh` 脚本，监听壁纸变化
  - 创建 `home/common/wallpaper-watcher.nix` Home Manager 模块
  - 支持通过 Noctalia-Shell/DMS-Shell 界面选择壁纸后自动触发配色更新
- 根据 NixOS 26.05 语法检查所有 Nix 代码
- **优化鼠标侧键配置**：在 Hyprland 中添加 `pass` 绑定（Button 8/9），让应用程序（如 Nemo、Firefox）能够正确处理后退/前进功能
- **更新 Qt 相关包名**：适配 NixOS 26.05 包库（`adwaita-qt` → `qt6Packages.adwaita-qt`，`qt6-multimedia` → `qt6Packages.qtmultimedia`，`fcitx5-qt` → `qt6Packages.fcitx5-qt`）
- **创建鼠标配置模块**：`modules/hardware/mouse.nix`，记录鼠标按钮编号说明和侧键处理策略

### Fixed

- 修复 fcitx5 包名问题：`fcitx5-chinese-addons` 和 `fcitx5-configtool` 需要 `qt6Packages` 前缀
- 修复鼠标侧键 Button 8/9 未生效问题：在 Hyprland 中添加 `pass` 绑定传递事件给应用程序
- 修复 `home/common/shell.nix` 中 `exa` 命令别名，改为 `eza`
- 修复 `qtwayland` 包引用问题，需要 `kdePackages` 前缀
- 修复 `polkit-kde-agent` 包引用问题，需要 `kdePackages.polkit-kde-agent-1`
- 修复代码中 `youruser` 占位符问题
- 修复 install.sh 与 flake.nix 主机类型配置冲突问题
- **修复 `modules/system/fonts.nix` 中无效的 `fonts.fontconfig.extraFonts` 选项**：改用 `fonts.fontconfig.localConf` 添加 XML 字体别名映射，并将字体包从 `environment.systemPackages` 移到 `fonts.packages`
- **修复 `install.sh` 生成配置不完整问题**：添加 `polkitAgent` 选项支持，初始化 `POWER_MANAGEMENT` 变量避免未定义行为
- **修复 `modules/desktops/unified-theme.nix` 中重复的 `environment.systemPackages` 定义**：合并为一个 `lib.mkAfter` 块，避免 NixOS 配置合并冲突
- **修复 `home/common/dev-lsp.nix` 中无效的 `programs.language-servers` 选项**：移除不存在的 Home Manager 选项，仅保留 `home.packages`
- **修复 `home/common/input.nix` 中无效的 `programs.fcitx5` 选项**：移除不存在的 Home Manager 选项，保留 `xdg.configFile` RIME 配置
- **修复 `modules/desktops/unified-theme.nix` 中重复的 `environment.etc` 定义**：将壁纸目录和 GTK/Qt 配置文件合并到同一个 `environment.etc` 块中

### Removed

- 移除 Stylix 主题框架
- 移除 Xorg 工具（xorg.xinit、xorg.xrandr）
- 移除非必要的显示管理器（保留 SDDM）
- 移除 overlays 目录（未使用）
- 移除所有硬件配置模板文件（改为安装时自动生成）

## [2026-06-10]

### Added

- 项目初始化：基于 NixOS 26.05 的现代化配置仓库
- Hyprland 0.55.2 窗口管理器配置（通过 hyprnix 管理）
- Niri 窗口管理器配置
- DMS-Shell 轻量级桌面 Shell
- Noctalia-Shell 现代化桌面集成 Shell
- Fcitx5 + RIME 输入法配置（使用 oh-my-rime）
- GTK/Qt 主题和图标统一配置
- 交互式安装脚本（scripts/install.sh）
- SDDM 显示管理器配置（仅 Wayland 模式）
- 用户级工具配置（neovim、emacs、yazi、vlc、eza、bat）
- UEFI 引导配置（systemd-boot，保留3个开机选项）
- 模块化架构：系统配置、用户配置、硬件配置分离
- 国内镜像源配置（中科大、清华、北外镜像）加速二进制包下载
- 安装脚本支持自动生成硬件配置

### Changed

- 许可证从 MIT 变更为 GNU GPL v3.0

### Fixed

- 修复 `home/common/input.nix` 中重复的包定义问题

## [2026-06-09]

### Added

- 完成安装脚本（scripts/install.sh）开发
  - 支持输入用户名、主机名、Git 信息
  - 支持选择主机类型（Desktop/Laptop/Server）
  - 支持选择窗口管理器（Hyprland/Niri）
  - 支持选择桌面 Shell（DMS-Shell/Noctalia-Shell）
  - 自动生成主机配置和用户配置

### Changed

- 优化项目结构，模块化拆分配置文件
- 更新 flake.nix 使用 `mkHost` 函数统一管理主机配置

## [2026-06-08]

### Added

- 配置 Hyprland 使用 Lua 语法
- 添加 Niri 窗口管理器模块
- 添加 DMS-Shell 和 Noctalia-Shell 模块
- 优化主题统一配置（GTK/Qt/图标）

### Changed

- 移除 stylix 主题框架

## [2026-06-07]

### Added

- 初始化项目结构
- 添加基础系统模块（common.nix、security.nix、network.nix）
- 添加硬件模块（蓝牙、输入法）
- 添加 Home Manager 用户配置

