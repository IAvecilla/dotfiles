{
  description = "macOS system configuration with nix-darwin and home-manager";

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
    paneru = {
      url = "github:karinushka/paneru";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, paneru, ... }:
    let
      # Change this to your system architecture
      # "aarch64-darwin" for Apple Silicon (M1/M2/M3/M4)
      # "x86_64-darwin" for Intel Macs
      system = "aarch64-darwin";

      # Change this to your username
      username = "ignacioavecilla";

      # Change this to your hostname (run `hostname` to check)
      hostname = "Ignacios-MacBook-Pro-2";
    in {
      # nix-darwin configuration
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit username;
        };
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit username paneru;
            };
            home-manager.users.${username} = import ./home.nix;
          }
        ];
      };

      # Keep standalone home-manager for compatibility
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ ./home.nix ];
        extraSpecialArgs = {
          inherit username paneru;
          dotfilesDir = self + "/..";
        };
      };
    };
}
