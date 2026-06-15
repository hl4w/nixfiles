{ pkgs, lib, ... }:

{
  boot = {
    plymouth = {
      enable = true;
      theme = "bgrt";  # 使用 bgrt 主题（BIOS/UEFI 背景主题）
      # 可选：自定义字体和 logo
      # font = "${pkgs.hack-font}/share/fonts/truetype/Hack-Regular.ttf";
      # logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";
    };
    # NixOS 26.05 中 boot.initrd.systemd.enable 已成为默认值，无需显式设置
    # 但保留在此处作为文档说明，表明 Plymouth 需要 systemd initrd
  };
}