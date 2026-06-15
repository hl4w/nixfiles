{ pkgs, config, ... }:

{
  imports = [
    ./shell.nix
    ./editor.nix
    ./cli.nix
    ./git.nix
    ./dev-lsp.nix
    ./wallpaper-watcher.nix
  ];
}