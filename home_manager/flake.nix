{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # Change this to your system architecture
      # "aarch64-darwin" for Apple Silicon (M1/M2/M3/M4)
      # "x86_64-darwin" for Intel Macs
      system = "aarch64-darwin";

      pkgs = nixpkgs.legacyPackages.${system};

      # Change this to your username
      username = "ignacioavecilla";
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { inherit username; dotfilesDir = self + "/.."; };
      };
    };
}
