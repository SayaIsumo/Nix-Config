{
  description = "Saya's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-desktop-nix.url = "github:tomsch/claude-desktop-nix";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      claude-desktop-nix,
      ...
    }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            {
              environment.systemPackages = [
                claude-desktop-nix.packages.x86_64-linux.default
              ];
              environment.etc."nix/inputs/nixpkgs".source = nixpkgs.outPath;
              nix.settings.nix-path = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
              nix.registry.nixpkgs.flake = nixpkgs;
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.saya = import ./home;
            }
          ];
        };
      };
    };
}
