{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    matugen = {
      url = "github:/InioX/Matugen";
    };
    nixcord.url = "github:FlameFlag/nixcord";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      zen-browser,
      quickshell,
      spicetify-nix,
      matugen,
      nixcord,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

      nixosConfigurations = {
        stan-pc = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/stan-pc/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.stan = import ./users/stan/home.nix;
                backupFileExtension = "backup";
              };

              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
        stan-laptop = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/stan-laptop/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.stan = import ./users/stan/home.nix;
                backupFileExtension = "backup";
              };

              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
      };
    };
}
