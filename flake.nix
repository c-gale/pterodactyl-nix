{
  description = "Reusable flake for Pterodactyl NixOS modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      # Build any reusable packages for all systems
      commonPackages = flake-utils.lib.eachDefaultSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          panel = import ./packages/panel.nix { inherit pkgs; };
          wings = import ./packages/wings.nix { inherit pkgs; };
        }
      );
    in

    {
      # Export modules at top level
      nixosModules = {
        pterodactyl-panel = ./modules/panel.nix;
        pterodactyl-wings = ./modules/wings.nix;
      };

      # Export packages under the normal structure
      packages = commonPackages;

      # You *can* also export devShells, apps, etc., if desired
      devShells = flake-utils.lib.eachDefaultSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ pkgs.git ];
          };
        }
      );
    };
}
