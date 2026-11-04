# HL4W NixOS 配置 Flake 文件
# 项目入口文件，定义输入和输出配置
# Version: v0.0.6
#
# 注意: Nix 语法规则 —— let ... in 必须包裹整个顶层 attrset，
#       不能作为 attrset 内部属性之间的语句插入。
#       本文件的 substituters / trusted-public-keys 在 outputs 中也需要用到，
#       所以必须放在顶层 let 里。
let
  # 二进制缓存源（国内镜像加速）
  substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"  # 中科大镜像（推荐）
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"  # 清华镜像
    "https://mirrors.bfsu.edu.cn/nix-channels/store"  # 北外镜像
    "https://cache.nixos.org"  # 官方源（备用）
  ];
  # 信任的公钥（用于验证缓存签名）
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
in {
  description = "HL4W NixOS configuration with Home Manager - Hyprland/Niri";

  nixConfig = {
    inherit substituters trusted-public-keys;
    # 实验性功能
    experimental-features = [ "nix-command" "flakes" ];
    # 自动优化存储
    auto-optimise-store = true;
  };

  # Flake 输入源
  inputs = {
    # NixOS 26.05 稳定版
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Home Manager 26.05 版本（与 nixpkgs 同步）
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # oh-my-rime RIME 输入法配置框架（薄荷拼音）
    # 仓库: https://github.com/Mintimate/oh-my-rime
    oh-my-rime = {
      url = "github:Mintimate/oh-my-rime/main";
      flake = false;  # 非 flake 仓库，仅作为源码输入
    };
  };

  # Flake 输出配置
  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
    inherit substituters trusted-public-keys;
    # 默认用户名占位符：install.sh 会用精确字符串匹配 `"youruser"` 替换
    # 注意：用户名必须是合法 Nix attr（仅字母、数字、下划线），不能含 `.` `-`
    USERNAME = "youruser";

    # 主机配置生成函数
    # 参数: name - 主机名称（对应 hosts/{name}/configuration.nix）
    mkHost = name: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # 导入主机特定配置
        ./hosts/${name}/configuration.nix
        # 导入 Home Manager 作为 NixOS 模块
        # release-26.05: nixosModules.home-manager = ./nixos
        home-manager.nixosModules.home-manager
        # Home Manager 用户配置 + 向 HM 模块注入 flake inputs
        # - home-manager.users.<name> 声明 HM 管理的用户
        # - home-manager.extraSpecialArgs 把 inputs 传给每个 HM 模块
        #   （home/common/*.nix 才能解构到 { inputs } 来消费 oh-my-rime 等源码输入）
        {
          home-manager.users.${USERNAME} = import ./home/hosts/${name}.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
      # 向 NixOS 模块注入参数：inputs + 缓存镜像配置
      specialArgs = {
        inherit inputs;
        nixSubstituters = substituters;
        nixTrustedPublicKeys = trusted-public-keys;
      };
    };
  in {
    # NixOS 配置输出（由 install.sh 动态追加条目）
    # 例如: "my-host" = mkHost "my-host";
    nixosConfigurations = {
    };
  };
}
