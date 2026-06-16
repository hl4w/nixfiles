# HL4W NixOS 配置 Flake 文件
# 项目入口文件，定义输入和输出配置
# Version: v0.0.5
{
  description = "HL4W NixOS configuration with Home Manager - Hyprland/Niri";

  # 共享配置变量（供系统和 flake 共同使用）
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
  in

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
    
    # Hyprland 工具链（用于管理 Hyprland 配置）
    hyprnix.url = "github:hyprwm/hyprnix/main";
  };

  # Flake 输出配置
  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
    inherit substituters trusted-public-keys;
    USERNAME = "youruser";  # 默认用户名（安装时会替换）
    
    # 主机配置生成函数
    # 参数: name - 主机名称（对应 hosts/{name}/configuration.nix）
    mkHost = name: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # 导入主机特定配置
        ./hosts/${name}/configuration.nix
        # 导入 Home Manager 模块
        home-manager.nixosModules.home-manager
        # Home Manager 用户配置
        {
          home-manager.users.${USERNAME} = import ./home/hosts/${name}.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
      specialArgs = {
        inherit inputs;
        # 传递缓存配置给系统模块
        nixSubstituters = substituters;
        nixTrustedPublicKeys = trusted-public-keys;
      };
    };
  in {
    # NixOS 配置输出（由安装脚本动态生成）
    nixosConfigurations = {
    };
  };
}
