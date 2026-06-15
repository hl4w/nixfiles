{ pkgs, config, inputs, ... }:

{
  imports = [
    ../common/default.nix
    ../common/input.nix
    ../common/apps.nix
    # 导入桌面特定用户级配置
    ./desktop/default.nix
  ];
}