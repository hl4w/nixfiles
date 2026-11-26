# fastfetch 配置
#
# 生成 ~/.config/fastfetch/config.jsonc（JSONC：fastfetch 原生格式，允许注释）。
# 显示时机由 home/common/shell.nix 控制：每次登录只会由第一个终端窗口执行一次。
#
# 手动预览：fastfetch
# 只看某模块：fastfetch -s cpu:gpu:memory
{ ... }:

{
  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",

      // NixOS 官方 logo；padding 控制 logo 与信息之间的留白
      "logo": {
        "type": "builtin",
        "source": "nixos",
        "padding": { "top": 1, "right": 2 }
      },

      // 键值分隔符
      "display": {
        "separator": " ➜ "
      },

      "modules": [
        "title",
        "separator",
        "os",
        "host",
        "kernel",
        "uptime",
        "packages",
        "break",
        "wm",
        "de",
        "shell",
        "terminal",
        "break",
        "cpu",
        "gpu",
        "memory",
        "swap",
        { "type": "disk", "folders": "/" },
        "break",
        "localip",
        "locale",
        { "type": "datetime", "key": "Time" },
        "break",
        "colors"
      ]
    }
  '';
}
