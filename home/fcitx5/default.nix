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
            sha256 = lib.fakeSha256;
          };
        }
      ];
    };
  };


}
