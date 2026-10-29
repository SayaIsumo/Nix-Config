{
  description = "Saya's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      claude-desktop,
      ...
    }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            {
              environment.etc."nix/inputs/nixpkgs".source = nixpkgs.outPath;
              nix.settings.nix-path = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
              nix.registry.nixpkgs.flake = nixpkgs;
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit claude-desktop; };
              home-manager.users.saya = import ./home;
            }
          ];
        };
      };
    };
}
