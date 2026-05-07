{
  description = "Silas Zhang's NixOS 25.11 Flake (Kui & Qingyu)";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs.url = "https://mirrors.ustc.edu.cn/nix-channels/nixos-25.11/nixexprs.tar.xz";
    home-manager = {
      #url = "github:nix-community/home-manager/release-25.11";
      url = "https://gitee.com/silaszk/home-manager/repository/archive/release-25.11.zip";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      #url = "github:noctalia-dev/noctalia-shell";
      url = "https://gitee.com/silaszk/noctalia-shell/repository/archive/main.zip";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-qs = {
      #url = "github:noctalia-dev/noctalia-shell";
      url = "https://gitee.com/silaszk/noctalia-qs/repository/archive/master.zip";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, noctalia, noctalia-qs,  ... }@inputs:
    let
      username = "silas";
      hostname = "nixos";
      specialArgs = { inherit username hostname; };
    in {
      nixosConfigurations."${hostname}" = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts
          ./users/nixos.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = inputs // specialArgs;
            home-manager.users.${username} = import ./users/home.nix;
          }
        ];
      };
    };
}