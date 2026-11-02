{ pkgs, config, ... }:

{
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
    signing = {
      key = "your-gpg-key-id";
      signByDefault = true;
      # Home Manager 25.05+ signing.format 不再默认 "openpgp"
      # 使用 GPG 签名必须显式设置为 "openpgp"
      format = "openpgp";
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