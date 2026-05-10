{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" "python" "sudo" "fzf" "colored-man-pages" ];
      theme = "agnoster";

      extraConfig = ''
        # 添加自定义别名
        alias ls='eza --icons'
        alias ll='eza -l --icons'
        alias la='eza -la --icons'
        alias tree='eza --tree --icons'
      '';
    };
  };

  # 启用 Foot
  programs.foot = {
    enable = true;
    package = pkgs.foot;

    # 启用服务器模式（推荐）
    server.enable = true;

    # 核心配置（生成 ~/.config/foot/foot.ini）
    settings = {
      # 主设置
      main = {
        term = "xterm-256color"; # 兼容远程 SSH 配色
        font = "Fira Code:size=11"; # 等宽字体
        dpi-aware = "yes";
        shell = "${pkgs.bash}/bin/bash";
      };

      colors = rec {
        alpha = 0.95;
        foreground = "b4c8aa"; # 淡青绿
        background = "0f0e0a"; # 墨绿黑
      };

      # 鼠标
      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}