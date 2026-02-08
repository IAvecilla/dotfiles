{
  description = "Cross-platform system configuration with nix-darwin and home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake.url = "github:sodiboo/niri-flake";
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, niri-flake, nixgl, ... }:
    let
      # macOS configuration
      darwinSystem = "aarch64-darwin";
      darwinUsername = "ignacioavecilla";
      darwinHostname = "Ignacios-MacBook-Pro-2";
      darwinDotfilesDir = "/Users/${darwinUsername}/misc/dotfiles";

      # Linux configuration
      linuxSystem = "x86_64-linux";
      linuxUsername = "nacho";
      linuxDotfilesDir = "/home/${linuxUsername}/dotfiles";
    in {
      # macOS: nix-darwin + home-manager
      darwinConfigurations.${darwinHostname} = nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = {
          username = darwinUsername;
        };
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              username = darwinUsername;
              dotfilesDir = darwinDotfilesDir;
            };
            home-manager.users.${darwinUsername} = import ./home.nix;
          }
        ];
      };

      # Linux: standalone home-manager with niri
      homeConfigurations.${linuxUsername} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${linuxSystem};
        modules = [
          ./home.nix
          ./linux.nix
          niri-flake.homeModules.niri
        ];
        extraSpecialArgs = {
          username = linuxUsername;
          dotfilesDir = linuxDotfilesDir;
          inherit nixgl;
        };
      };

      # macOS standalone home-manager (for compatibility)
      homeConfigurations.${darwinUsername} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${darwinSystem};
        modules = [ ./home.nix ];
        extraSpecialArgs = {
          username = darwinUsername;
          dotfilesDir = darwinDotfilesDir;
        };
      };
    };
}
