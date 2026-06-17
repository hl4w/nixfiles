# 系统级公共配置模块
# 包含所有主机类型共享的基础系统配置
{ pkgs, lib, nixSubstituters ? null, nixTrustedPublicKeys ? null, ... }:

{
  # 导入子模块
  imports = [
    ./fonts.nix  # 字体配置模块
  ];

  # 系统级安装的工具 - 所有用户均可使用
  environment.systemPackages = with pkgs; [
    git          # 版本控制工具
    wget         # 命令行下载工具
    curl         # 命令行下载工具
    tmux         # 终端复用工具
    bash         # Bash shell
    zsh          # Z shell
    tree         # 目录树显示
    highlight    # 代码语法高亮
    nixpkgs-fmt  # Nix 代码格式化工具
    nil          # Nix 语言服务器
  ];

  # 启用系统级程序配置
  programs.bash.enable = true;   # 启用 Bash 配置支持
  programs.zsh.enable = true;   # 启用 Zsh 配置支持
  programs.git.enable = true;   # 启用 Git 配置支持

  # Nix 配置
  # 使用 Lix 作为 Nix 实现（比原生 Nix 更快，兼容所有功能）
  nix = {
    package = pkgs.lix;
    settings = {
      # 二进制缓存源（从 flake 继承，如无则使用默认值）
      substituters = if nixSubstituters != null then nixSubstituters else [
        "https://mirrors.ustc.edu.cn/nix-channels/store"  # 中科大镜像
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"  # 清华镜像
        "https://cache.nixos.org"  # 官方源
      ];
      # 信任的公钥（从 flake 继承，如无则使用默认值）
      trusted-public-keys = if nixTrustedPublicKeys != null then nixTrustedPublicKeys else [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      auto-optimise-store = true;          # 自动优化 Nix store
      experimental-features = [ "nix-command" "flakes" ];  # 启用 Nix 命令和 Flakes
    };
    gc = {
      # 自动垃圾回收配置
      automatic = true;                      # 启用自动垃圾回收
      dates = "weekly";                      # 每周执行一次
      options = "--delete-older-than 7d";    # 删除 7 天前的旧版本
    };
    # 保留最近 3 个系统版本
    extraOptions = ''
      keep-derivations = true
      keep-outputs = true
    '';
  };
  # 使用 overlay 确保依赖 Nix 的工具也使用 Lix
  nixpkgs.overlays = [
    (final: prev: {
      nixpkgs-review = prev.lixPackages.nixpkgs-review;
      nix-eval-jobs = prev.lixPackages.nix-eval-jobs;
    })
  ];

  # 系统环境变量和别名
  environment.shellAliases = {
    ls = "eza --icons";       # 使用 eza 替代 ls
    ll = "eza --icons -la";   # 详细列表显示
    grep = "grep --color=auto";  # 彩色 grep 输出
  };

  # 系统本地化配置 - 完整中文支持
  time.timeZone = "Asia/Shanghai";    # 时区：上海
  i18n = {
    defaultLocale = "zh_CN.UTF-8";    # 默认语言：中文
    locales = [                       # 支持的语言环境
      "zh_CN.UTF-8 UTF-8"
      "en_US.UTF-8 UTF-8"
    ];
  };
  
  # 控制台字体和键盘
  console = {
    font = "Lat2-Terminus16";         # 控制台字体（英文）
    keyMap = "us";                    # 控制台键盘布局
  };

  # 系统环境变量
  environment.variables = {
    LANG = "zh_CN.UTF-8";             # 语言环境变量
    LC_ALL = "zh_CN.UTF-8";           # 所有本地化设置
    LC_TIME = "zh_CN.UTF-8";          # 时间格式
    LC_MESSAGES = "zh_CN.UTF-8";      # 消息语言
  };

  # 限制启动项数量为最近 3 个
  systemd = {
    tmpfiles.rules = [
      # 清理旧的系统配置（保留最近 3 个版本）
      "d /boot/loader/entries - - - - 3"
    ];
  };

  # 限制 systemd-boot 配置数量
  boot.loader.systemd-boot.configurationLimit = 3;
}