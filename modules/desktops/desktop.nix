# 桌面环境配置模块
# 支持动态选择窗口管理器和桌面 shell
{ pkgs, lib, config, ... }:

let
  cfg = config.desktop;
in

{
  options.desktop = {
    windowManager = lib.mkOption {
      type = lib.types.enum [ "hyprland" "niri" ];
      default = "hyprland";
      description = "选择窗口管理器";
    };

    shell = lib.mkOption {
      type = lib.types.enum [ "dms" "noctalia" ];
      default = "dms";
      description = "选择桌面 shell";
    };

    enableInputMethod = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "是否启用输入法";
    };

    polkitAgent = lib.mkOption {
      type = lib.types.enum [ "kde" "hyprland" ];
      default = "kde";
      description = "选择 polkit 代理：kde (polkit-kde-agent-1) 或 hyprland (hyprpolkitagent)";
    };
  };

  # imports 必须与 config 无关：imports 在选项合并之前求值，
  # 引用 cfg 会导致 infinite recursion（正是 NixOS 报错提示的场景）。
  # 因此这里无条件导入所有桌面模块，把条件逻辑下放到各模块内部的 lib.mkIf。
  imports = [
    ./sddm.nix
    ./unified-theme.nix              # 系统级主题（Qt/SDDM/环境变量）
    ./hyprland.nix                   # 内部按 windowManager == "hyprland" 生效
    ./niri.nix                       # 内部按 windowManager == "niri" 生效
    ./shell-dms.nix                  # 内部按 shell == "dms" 生效
    ./shell-noctalia.nix             # 内部按 shell == "noctalia" 生效
    ../input-method/default.nix      # 内部按 enableInputMethod 生效
  ];

  config = {
    # 系统级包配置
    environment.systemPackages =
      (with pkgs; [
        # Adwaita 主题（qt6Packages 集合中无 adwaita-qt，仅顶层同名包）
        adwaita-qt                    # Adwaita 主题（跟随 nixpkgs 默认 Qt 版本）
        gnome.adwaita-icon-theme      # Adwaita 图标主题
        gnome.gnome-themes-extra      # GTK 主题支持
      ])
      # polkit 代理：条件性包不能放在 systemPackages 列表里用 mkIf，改用 lib.optional
      ++ lib.optional (cfg.polkitAgent == "kde") pkgs.kdePackages.polkit-kde-agent-1
      ++ lib.optional (cfg.polkitAgent == "hyprland") pkgs.hyprpolkitagent;
  };
}
