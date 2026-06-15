{ pkgs, config, inputs, ... }:

{
  imports = [
    ../common/default.nix
    # 导入服务器特定用户级配置
    ./server/default.nix
  ];
}