{ pkgs, config, ... }:

{
  # 复制项目壁纸目录到用户目录
  home.file.".wallpapers".source = ./../../wallpapers;
  home.file.".wallpapers".recursive = true;
  
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
    };
    prompt = "starship";
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

  programs.starship = {
    enable = true;
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
        unstaged = "[✗]($color1)";
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
    cd.. = "cd ..";
    .. = "cd ..";
    ... = "cd ../..";
  };
}