{ config, pkgs, lib, ... }:

let
  oh-my-rime = pkgs.fetchzip {
    url = "https://cnb.cool/Mintimate/rime/oh-my-rime/-/releases/download/latest/oh-my-rime.zip";
    sha256 = "sha256-cSyGQhGJh5wTnArN1hmyaFJuFNILEc/7hcBvd2APfyQ=";
    stripRoot = false;
  };

  fcitx-catppucin = pkgs.fetchzip {
    url = "https://mirror.ghproxy.com/https://github.com/catppuccin/fcitx5/archive/refs/heads/main.zip";
    sha256 = "sha256-hHgDWbFjLgN1hK+cHGZ8iJ2JzJ2wCwGJk9L6H8RjS8Y=";
    stripRoot = false;
  };

in {
  # 输入法基础配置
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-rime ];
  };

  # 2. 用 home.activation 钩子复制配置
  home.activation.linkRimeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p $HOME/.local/share/fcitx5
    TARGET_DIR="$HOME/.local/share/fcitx5/rime"
    #BACKUP_DIR="$TARGET_DIR.backup.$(date +%Y%m%d_%H%M%S)"

    # 备份旧目录（如果存在且不是软链接）
    #if [ -d "$TARGET_DIR" ] && [ ! -L "$TARGET_DIR" ]; then
    #  run mv "$TARGET_DIR" "$BACKUP_DIR"
    #  echo "Existing directory moved to $BACKUP_DIR"
    #fi

    # 直接复制 Nix 里的 oh-my-rime 到目标目录（不再用 unzip）
    run cp -rf ${oh-my-rime}/* "$TARGET_DIR/"
    run chmod -R u+rwX "$TARGET_DIR"
    echo "Oh-my-rime copied to $TARGET_DIR"
  '';

  # 3. 自定义默认方案（覆盖默认）
  home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
    patch:
      menu:
        page_size: 6
      schema_list:
        - schema: rime_mint
        - schema: rime_mint_fluency
  '';


  # --------------------------
  # 加载 Catppuccin 主题
  # --------------------------
  home.sessionVariables.FCITX5_ADDITIONAL_THEMES = "${catppuccin-fcitx5}/themes";

  # --------------------------
  # 设置默认主题（mocha 深色）
  # --------------------------
  xdg.configFile."fcitx5/conf/ui.conf".text = ''
    [General]
    Theme=catppuccin-mocha
  ''; 

}