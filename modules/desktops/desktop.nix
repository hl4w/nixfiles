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

  # imports 是模块级属性，不能写在 config 里（否则会报 `imports` 选项不存在）。
  # 条件导入用 lib.optional（返回列表，可与其他导入项拼接），
  # 不能用 lib.mkIf 包裹裸路径——那会被模块系统当作"path 类型的选项定义"而报错。
  imports =
    [
      ./sddm.nix
      ./unified-theme.nix              # 系统级主题（Qt/SDDM/环境变量）
    ]
    ++ lib.optional (cfg.windowManager == "hyprland") ./hyprland.nix
    ++ lib.optional (cfg.windowManager == "niri") ./niri.nix
    ++ lib.optional (cfg.shell == "dms") ./shell-dms.nix
    ++ lib.optional (cfg.shell == "noctalia") ./shell-noctalia.nix
    ++ lib.optional cfg.enableInputMethod ../input-method/default.nix;

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
