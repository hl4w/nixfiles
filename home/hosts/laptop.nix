{ pkgs, config, inputs, ... }:

{
  imports = [
    ../common/default.nix
    ../common/input.nix
    ../common/apps.nix
    # 导入笔记本特定用户级配置
    ./laptop/default.nix
  ];
}