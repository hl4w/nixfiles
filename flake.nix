# HL4W NixOS 配置 Flake 文件
# 项目入口文件，定义输入和输出配置
# Version: v0.0.6
#
# 重要: Nix flake evaluator 要求 flake.nix 顶层表达式必须是纯 attrset { ... }，
#       不能是 `let ... in { ... }`（这在标准 Nix 语义下合法，但 flake 解析器拒绝）。
#       因此 substituters / trusted-public-keys 在 outputs 的 inner let 中重新定义。

{
  description = "HL4W NixOS configuration with Home Manager - Hyprland/Niri";

  # Nix 全局配置（缓存源 + 实验性功能）
  nixConfig = {
    # 二进制缓存源（国内镜像加速，官方源作为兜底）
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"         # 中科大镜像
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" # 清华镜像
      "https://mirrors.bfsu.edu.cn/nix-channels/store"         # 北外镜像
      "https://cache.nixos.org"                                # 官方源
    ];
    # 信任的公钥（验证缓存签名）
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    # 实验性功能（flakes + nix-command 是必需的）
    experimental-features = [ "nix-command" "flakes" ];
    # 自动优化 Nix store 存储
    auto-optimise-store = true;
  };

  # ============================================================
  # Flake 输入源
  # ============================================================
  inputs = {
    # NixOS 26.05 稳定版（tagged release，不是 rolling）
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Home Manager 26.05 版本（与 nixpkgs 同步）
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ------------------------------------------------------------
    # oh-my-rime RIME 输入法配置框架（薄荷拼音）
    # 默认源: https://cnb.cool/Mintimate/rime/oh-my-rime（CNB 官方镜像，国内访问稳定，默认分支 main）
    # 上游仓库: https://github.com/Mintimate/oh-my-rime（默认分支 main）
    #
    # 如需回到 GitHub 上游，把下面第 1 行注释掉、启用第 2 行即可；
    # 切换后需刷新该输入对应的锁文件条目: nix flake update oh-my-rime
    # ------------------------------------------------------------
    oh-my-rime = {
      url = "git+https://cnb.cool/Mintimate/rime/oh-my-rime";
      # url = "github:Mintimate/oh-my-rime/main";
      flake = false;  # 非 flake 仓库，仅作为源码输入给 modules 使用
    };
  };

  # ============================================================
  # Flake 输出配置
  # ============================================================
  # 签名: outputs = { self, nixpkgs, home-manager, oh-my-rime, ... }@inputs:
  # inputs 绑定所有 inputs + self，可在 outputs 内自由使用
  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
    # 缓存配置 —— outputs 内的模块（modules/system/default.nix）需要消费
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.bfsu.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # 默认用户名占位符
    # install.sh 会精确匹配字符串 "youruser" 并替换为实际用户名
    # 注意: 用户名必须是合法 Nix attr（仅字母、数字、下划线），不能含 `.` `-`
    USERNAME = "youruser";

    # 主机配置生成函数
    # 参数: name - 主机名称（对应 hosts/{name}/configuration.nix + home/hosts/{name}.nix）
    mkHost = name: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # ① 主机特定配置（文件必须存在: hosts/${name}/configuration.nix）
        ./hosts/${name}/configuration.nix

        # ② Home Manager 作为 NixOS 模块
        #    release-26.05 官方路径: home-manager.nixosModules.home-manager = ./nixos
        #    导入后即可在下方模块属性中写 home-manager.users / home-manager.extraSpecialArgs
        home-manager.nixosModules.home-manager

        # ③ Home Manager 用户绑定 + 注入 flake inputs 给 HM 模块
        {
          # 用占位符用户名声明 HM 管理的用户
          # install.sh 替换 flake.nix USERNAME 后，这里会自动匹配
          home-manager.users.${USERNAME} = import ./home/hosts/${name}.nix;

          # 把所有 flake inputs 注入给 HM 模块（home/common/*.nix 才能解构 { inputs }）
          # 这是 HM 模块消费外部源码输入（oh-my-rime）的唯一途径
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];

      # 向所有 NixOS 模块注入参数（通过 config.specialArgs 可解构）
      # - inputs:    让 NixOS 模块也能消费 flake 输入（如 oh-my-rime）
      # - 缓存配置:  modules/system/default.nix 会 null-coalesce 到这些值
      specialArgs = {
        inherit inputs;
        nixSubstituters = substituters;
        nixTrustedPublicKeys = trusted-public-keys;
      };
    };
  in {
    # ============================================================
    # NixOS 配置输出
    # ============================================================
    # install.sh 会在运行时动态追加条目，例如:
    #   "my-hostname" = mkHost "my-hostname";
    # 构建命令: nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
    # 部署命令: sudo nixos-rebuild switch --flake .#<hostname>
    nixosConfigurations = {
    };
  };
}
