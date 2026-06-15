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

  config = lib.mkIf (cfg.windowManager != "") {
    # 根据窗口管理器选择导入相应模块
    imports = [
      ./sddm.nix
      (lib.mkIf (cfg.windowManager == "hyprland") ./hyprland.nix)
      (lib.mkIf (cfg.windowManager == "niri") ./niri.nix)
      (lib.mkIf (cfg.shell == "dms") ./shell-dms.nix)
      (lib.mkIf (cfg.shell == "noctalia") ./shell-noctalia.nix)
      (lib.mkIf cfg.enableInputMethod ../input-method/default.nix)
    ];

    # 系统级包配置
    environment.systemPackages = with pkgs; [
      # polkit 代理
      (lib.mkIf (cfg.polkitAgent == "kde") kdePackages.polkit-kde-agent-1)
      (lib.mkIf (cfg.polkitAgent == "hyprland") hyprpolkitagent)
      
      # Qt6 核心主题工具（统一 GTK/Qt 主题）
      qt6Packages.adwaita-qt        # Qt6 Adwaita 主题
      adwaita-qt                    # Qt5 Adwaita 主题（兼容性）
      gnome.adwaita-icon-theme      # Adwaita 图标主题
      gnome.gnome-themes-extra      # GTK 主题支持
    ];
  };
}