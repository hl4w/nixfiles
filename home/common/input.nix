# 用户级输入法配置 - RIME + oh-my-rime（薄荷拼音）
#
# 依赖 flake input: inputs.oh-my-rime (github:Mintimate/oh-my-rime)
#
# 设计说明:
# - oh-my-rime 不是 nixpkgs 包，而是 RIME 配置模板集合，通过 flake input 拉取
# - 将 oh-my-rime 的 schema/dict/lua 等文件以符号链接方式部署到 fcitx5-rime
#   的数据目录 ~/.local/share/fcitx5/rime/
# - 目录本身保持可写（仅文件为 symlink），RIME 可在其中写入用户词典和状态文件
# - 排除平台专属配置（Windows Weasel / macOS Squirrel / Android Trime / ibus）
# - installation.yaml 由 RIME 自动生成（需要可写），因此不通过 home-manager 管理，
#   改用 default.custom.yaml 覆盖 schema_list 来指定启用的输入法方案
{ pkgs, config, inputs, lib, ... }:

let
  ohMyRime = inputs.oh-my-rime;

  # 判断是否为需要部署到 RIME 数据目录的资源
  # 排除: 隐藏文件、文档、图片、许可证、平台专属配置
  isRimeResource = name: type:
    (type == "regular" || type == "directory") &&
    !(lib.hasPrefix "." name) &&
    !(lib.hasSuffix ".md" name) &&
    !(lib.hasSuffix ".webp" name) &&
    !(lib.hasSuffix ".png" name) &&
    !(lib.hasSuffix ".jpg" name) &&
    name != "LICENSE" &&
    name != "weasel.yaml" &&       # Windows (Weasel) 专属
    name != "squirrel.yaml" &&     # macOS (Squirrel) 专属
    name != "trime.yaml" &&        # Android (Trime) 专属
    name != "ibus_rime.yaml";      # ibus 专属（本项目使用 fcitx5）

  # 从 oh-my-rime 仓库筛选需要的文件和目录
  rimeResources = lib.filterAttrs isRimeResource (builtins.readDir ohMyRime);

  # 生成 home.file 条目：将 oh-my-rime 的文件符号链接到 fcitx5-rime 数据目录
  rimeHomeFiles = lib.mapAttrs' (name: _type: {
    name = ".local/share/fcitx5/rime/${name}";
    value = { source = "${ohMyRime}/${name}"; };
  }) rimeResources;
in
{
  # 部署 oh-my-rime 配置文件到 fcitx5-rime 数据目录
  home.file = rimeHomeFiles // {
    # 通过 default.custom.yaml 覆盖 schema_list，指定启用的输入法方案
    # RIME 首次运行时会根据 default.yaml + default.custom.yaml 生成 installation.yaml
    # 注意: *.custom.yaml 是只读的用户定制文件，RIME 只读取不写入，symlink 安全
    ".local/share/fcitx5/rime/default.custom.yaml".text = ''
      patch:
        schema_list:
          - schema: rime_mint          # 薄荷拼音（简体，默认方案）
          - schema: rime_mint_flypy    # 薄荷小鹤双拼
          - schema: terra_pinyin       # 地球拼音（带声调）
          - schema: stroke             # 笔画输入
    '';

    # Fcitx5 Classic UI 主题配置
    # 主题包: pkgs.catppuccin-fcitx5（在 modules/input-method/default.nix 中作为 addon 安装）
    # 主题名称格式: catppuccin-{flavor}-{accent}
    #   flavor: latte（亮）、frappe、macchiato、mocha（暗，默认）
    #   accent: rosewater、flamingo、pink、mauve（默认）、red、maroon、peach、
    #           yellow、green、teal、sky、sapphire、blue、lavender
    # 切换主题只需修改 Theme 值后执行: fcitx5 -r
    ".config/fcitx5/conf/classicui.conf".text = ''
      Theme=catppuccin-mocha-mauve
    '';
  };
}
