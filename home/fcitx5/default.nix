{ config, pkgs, ... }:

{
  programs.fcitx5 = {
    enable = true;
    rime = {
      enable = true;
      customSchemes = [
        {
          name = "oh-my-rime";
          src = pkgs.fetchgit {
            url = "https://github.com/Mintimate/oh-my-rime.git";
            rev = "main";
          };
        }
      ];
    };
  };

  home.files.".local/share/fcitx5/rime" = {
    source = "oh-my-rime";
    recursive = true;
  };

}
