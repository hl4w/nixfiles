{ pkgs, config, ... }:

{
  # 复制项目壁纸目录到用户目录
  home.file.".wallpapers".source = ./../../wallpapers;
  home.file.".wallpapers".recursive = true;
  
  # Bash 配置
  programs.bash = {
    enable = true;
    initExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
      export EDITOR="nvim"
      export VISUAL="nvim"
      
      # pywal 颜色初始化 - 从壁纸提取的配色
      if [ -f "$HOME/.cache/wal/colors.sh" ]; then
          source "$HOME/.cache/wal/colors.sh"
      fi
      
      # 壁纸取色命令别名
      alias wp-color='${pkgs.writeScript "wallpaper-color" (builtins.readFile ./../../scripts/wallpaper-color.sh)}'
      alias wp-random='${pkgs.writeScript "wallpaper-color" (builtins.readFile ./../../scripts/wallpaper-color.sh)} -d'
      alias wp-apply='${pkgs.writeScript "wallpaper-color" (builtins.readFile ./../../scripts/wallpaper-color.sh)} -a'
      alias wp-list='${pkgs.writeScript "wallpaper-color" (builtins.readFile ./../../scripts/wallpaper-color.sh)} -l'
    '';
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
    };
    # 提示符由下面的 programs.starship 接管（enableZshIntegration），
    # Home Manager 的 zsh 模块没有 prompt 选项
    # Home Manager 26.05: zsh.initExtra 已废弃，改用 initContent
    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"
      export EDITOR="nvim"
      export VISUAL="nvim"
      
      # pywal 颜色初始化 - 从壁纸提取的配色
      if [ -f "$HOME/.cache/wal/colors.sh" ]; then
          source "$HOME/.cache/wal/colors.sh"
      fi
      
      # 壁纸取色命令别名
      alias wp-color='${pkgs.writeScript "wallpaper-color" (builtins.readFile ./../../scripts/wallpaper-color.sh)}'
      alias wp-random='${pkgs.writeScript "wallpaper-color" (builtins.readFile ./../../scripts/wallpaper-color.sh)} -d'
      alias wp-apply='${pkgs.writeScript "wallpaper-color" (builtins.readFile ./../../scripts/wallpaper-color.sh)} -a'
      alias wp-list='${pkgs.writeScript "wallpaper-color" (builtins.readFile ./../../scripts/wallpaper-color.sh)} -l'

      # 首次打开终端时展示系统信息（fastfetch）
      # 用 XDG_RUNTIME_DIR 下的标记文件判断：该目录按登录会话创建、
      # 注销时由 logind 清理，因此每次登录只有第一个终端窗口会显示，
      # 之后再开新窗口或嵌套子 shell 都不会重复打印。
      _ff_stamp="''${XDG_RUNTIME_DIR:-/tmp}/.fastfetch-shown-$(id -u)"
      if command -v fastfetch >/dev/null 2>&1 && [[ ! -e "$_ff_stamp" ]]; then
        fastfetch
        : > "$_ff_stamp"
      fi
      unset _ff_stamp
    '';
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      # 使用 pywal 生成的配色（颜色会在运行时替换）
      character = {
        success_symbol = "[➜]($color2)";
        error_symbol = "[✗]($color1)";
      };
      git_branch = {
        symbol = " ";
        style = "bold $color4";
      };
      git_status = {
        staged = "[✓]($color2)";
        # Starship 的 git_status 没有 unstaged 键，工作区改动用 modified
        modified = "[✗]($color1)";
      };
      directory = {
        style = "bold $color6";
      };
      package = {
        style = "bold $color5";
      };
    };
  };

  home.shellAliases = {
    ls = "eza --icons";
    ll = "eza --icons -la";
    la = "eza --icons -a";
    grep = "grep --color=auto";
    vim = "nvim";
    vi = "nvim";
    cat = "bat";
    # 属性名含点号 / 省略号，不是合法的 Nix 标识符，必须写成字符串形式
    "cd.." = "cd ..";
    ".." = "cd ..";
    "..." = "cd ../..";
  };
}