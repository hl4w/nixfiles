# 用户配置变量
# 运行 install.sh 后请将 USER 替换为实际用户名，或通过 make USER=<name> 传递
USER ?= youruser
HOST ?= desktop

.PHONY: all build switch-home switch update clean setup-direnv

all: build

build:
	nix build .#$(HOST)

switch-home:
	home-manager switch --flake .#$(USER)@$(HOST)

switch:
	sudo nixos-rebuild switch --flake .#$(HOST)

update:
	nix flake update

clean:
	nix store gc --print-roots

setup-direnv:
	direnv allow