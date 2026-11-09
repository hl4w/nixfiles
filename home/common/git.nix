{ pkgs, config, ... }:

{
  programs.git = {
    enable = true;
    signing = {
      key = "your-gpg-key-id";
      signByDefault = true;
    };
    # Home Manager 26.05: userName/userEmail/extraConfig 已合并进 settings.submodule
    settings = {
      user = {
        name = "Your Name";
        email = "your.email@example.com";
      };
      core = {
        editor = "nvim";
        pager = "less -FRX";
      };
      pull = {
        rebase = false;
      };
      push = {
        default = "simple";
      };
      color = {
        ui = "auto";
      };
    };
  };
}