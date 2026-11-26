# 系统级输入法配置 - NixOS 26.05 标准配置（仅 Wayland）
# 参考: https://wiki.nixos.org/wiki/Fcitx5
{ pkgs, lib, config, inputs, ... }:

let
  # WowType 智能拼音输入法（fcitx5 引擎，来自 flake input `wowtype`）
  # 与系统共用同一份 nixpkgs（inputs.nixpkgs.follows），保证 addon 与 fcitx5 版本一致
  wowtype = inputs.wowtype.packages.${pkgs.stdenv.hostPlatform.system}.default;
in

{
  config = lib.mkIf config.desktop.enableInputMethod {
    # 核心输入法配置 - NixOS 会自动设置环境变量
    i18n = {
      inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          waylandFrontend = true;   # Wayland 桌面支持
          # 仅支持 Wayland，移除 X11 支持
          # addons 会自动处理依赖，无需手动添加到 systemPackages
          addons = with pkgs; [
            fcitx5-rime                      # RIME 输入法引擎
            qt6Packages.fcitx5-chinese-addons # 中文输入法扩展（拼音、五笔等）
            fcitx5-gtk                       # GTK 应用支持
            qt6Packages.fcitx5-qt           # Qt6 应用支持（NixOS 26.05）
            catppuccin-fcitx5               # Catppuccin 配色主题（latte/frappe/macchiato/mocha）
            wowtype                         # WowType 整句拼音（需在 fcitx5 配置中启用，见下）
          ];
        };
      };
    };

    # GUI 配置工具（RIME 数据已由 oh-my-rime flake input 提供，无需额外安装 rime-data-*）
    environment.systemPackages = with pkgs; [
      qt6Packages.fcitx5-configtool  # GUI 配置工具
      wowtype                        # 提供 wowtype-config / wowtype-check / wowtype-show 命令
    ];

    # 首次启用 WowType：部署后执行一次 `wowtype-config --add-to-group`
    # 把 WowType 写入 fcitx5 的输入法列表（写入 ~/.config/fcitx5/profile，属于运行时状态，
    # 不在本仓库声明式管理范围内），随后 `fcitx5 -r` 或重新登录生效。
  };
}
