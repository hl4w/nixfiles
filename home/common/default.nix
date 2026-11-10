{ pkgs, config, ... }:

{
  # Home Manager 状态版本
  # 必须显式设置（HM 26.05 起无默认值），用于保持向后兼容性
  # 升级 HM 时不应自动修改此值，除非已阅读对应版本的发布说明
  home.stateVersion = "26.05";

  imports = [
    ./shell.nix
    ./editor.nix
    ./cli.nix
    ./git.nix
    ./dev-lsp.nix
    ./pywal.nix
    ./wallpaper-watcher.nix
  ];
}