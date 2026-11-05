FLAKE_DIR := home_manager

# Platform-specific switches
linux:
	cd $(FLAKE_DIR) && home-manager switch --flake .#nacho --impure

darwin:
	cd $(FLAKE_DIR) && sudo darwin-rebuild switch --flake .

# First-time setup (before home-manager is in PATH)
bootstrap-linux:
	cd $(FLAKE_DIR) && nix run nixpkgs#home-manager -- switch --flake .#nacho --impure

bootstrap-darwin:
	cd $(FLAKE_DIR) && nix run nix-darwin -- switch --flake .

# Update all flake inputs
update:
	cd $(FLAKE_DIR) && nix flake update

# Build without applying (dry run)
build-linux:
	cd $(FLAKE_DIR) && home-manager build --flake .#nacho --impure

build-darwin:
	cd $(FLAKE_DIR) && nix build .#darwinConfigurations.Ignacios-MacBook-Pro-2.system

# Rollback to previous generation
rollback-linux:
	home-manager switch --rollback

rollback-darwin:
	cd $(FLAKE_DIR) && darwin-rebuild switch --rollback

# List past generations
generations:
	home-manager generations

# Garbage collect old nix store entries
gc:
	nix store gc

.PHONY: linux darwin bootstrap-linux bootstrap-darwin update build-linux build-darwin rollback-linux rollback-darwin generations gc
