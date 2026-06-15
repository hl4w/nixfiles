.PHONY: all build switch-home switch update clean setup-direnv

all: build

build:
	nix build .#desktop

switch-home:
	home-manager switch --flake .#youruser@desktop

switch:
	sudo nixos-rebuild switch --flake .#desktop

update:
	nix flake update

clean:
	nix store gc --print-roots

setup-direnv:
	direnv allow