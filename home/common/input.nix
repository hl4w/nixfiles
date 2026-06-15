# 用户级输入法配置 - 专注于用户特定的个性化设置
{ pkgs, config, ... }:

{
  # 用户级 RIME 增强配置
  home.packages = with pkgs; [
    oh-my-rime  # RIME 配置增强框架
  ];

  # 下载 oh-my-rime 配置框架
  home.file.".config/oh-my-rime".source = pkgs.fetchFromGitHub {
    owner = "lotem";
    repo = "oh-my-rime";
    rev = "master";
    sha256 = pkgs.lib.fakeSha256;
  };

  # RIME 输入法方案配置
  xdg.configFile = {
    "rime/installation.yaml".text = ''
      patch:
        schema_list:
          - schema: luna_pinyin_simp  # 朙月拼音（简体）- 默认
          - schema: flypy              # 小鹤双拼
          - schema: bopomofo           # 注音
          - schema: terra_pinyin       # 地球拼音
        user_data_dir: ${config.home.homeDirectory}/.local/share/fcitx5/rime
    '';
    "rime/default.custom.yaml".text = ''
      patch:
        __patch:
          - ${config.home.homeDirectory}/.config/oh-my-rime/default.custom.yaml
    '';
    "rime/luna_pinyin.custom.yaml".text = ''
      patch:
        __patch:
          - ${config.home.homeDirectory}/.config/oh-my-rime/luna_pinyin.custom.yaml
    '';
    "rime/luna_pinyin_simp.custom.yaml".text = ''
      patch:
        __patch:
          - ${config.home.homeDirectory}/.config/oh-my-rime/luna_pinyin_simp.custom.yaml
    '';
    "rime/flypy.custom.yaml".text = ''
      patch:
        __patch:
          - ${config.home.homeDirectory}/.config/oh-my-rime/flypy.custom.yaml
    '';
    "rime/key_bindings.custom.yaml".text = ''
      patch:
        __patch:
          - ${config.home.homeDirectory}/.config/oh-my-rime/key_bindings.custom.yaml
    '';
  };
}
