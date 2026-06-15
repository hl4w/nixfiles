{ pkgs, config, ... }:

{
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
    signing = {
      key = "your-gpg-key-id";
      signByDefault = true;
    };
    extraConfig = {
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