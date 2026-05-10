{ config, pkgs, ... }:

let 
  oh-my-rime-src = pkgs.fetchFromGitHub {
    owner = "Mintimate";
    repo = "oh-my-rime";
    rev = "main";              # 建议使用固定的 commit hash
    sha256 = "sha256-J+wiB2X9qh2HuZ3F3Pbe4OyT3UzDdxTNZZzoHUA6uwuTs=";   # 首次运行报错后会给出正确值，替换即可
  };

in 
{
  home.packages = with pkgs; [ rime-data ];

  home.file = {
    # 将整个 oh-my-rime 目录链接到 fcitx5 的 rime 配置目录
    ".local/share/fcitx5/rime".source = oh-my-rime-src;
  };

}
