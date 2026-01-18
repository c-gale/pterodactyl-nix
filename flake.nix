{
  description = "Pterodactyl panel + wings"; 

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.pterodactylPanel = pkgs.callPackage ./default.nix {};
        packages.pterodactylWings = pkgs.callPackage ./wings.nix {};
        
        # If you have a NixOS module:
        nixosModules = {
          pterodactyl = ./module.nix;
        };
      };
}
