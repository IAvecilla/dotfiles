FLAKE_DIR := home_manager

# Platform-specific switches
linux:
	cd $(FLAKE_DIR) && home-manager switch --flake .#nacho --impure

darwin:
	cd $(FLAKE_DIR) && darwin-rebuild switch --flake .

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
rollback:
	home-manager switch --rollback

# List past generations
generations:
	home-manager generations

# Garbage collect old nix store entries
gc:
	nix store gc

# Setup niri as a GDM session option (requires sudo, run once)
setup-niri:
	@printf '[Desktop Entry]\nName=Niri\nComment=A scrollable-tiling Wayland compositor\nExec=$(HOME)/.nix-profile/bin/niri-session\nType=Application\nDesktopNames=niri\n' | sudo tee /usr/share/wayland-sessions/niri.desktop > /dev/null
	@sudo sed -i 's/WaylandEnable=false/WaylandEnable=true/' /etc/gdm3/custom.conf
	@echo "Niri session installed. Log out and select 'Niri' from the GDM login screen."

.PHONY: linux darwin bootstrap-linux bootstrap-darwin update build-linux build-darwin rollback generations gc setup-niri
