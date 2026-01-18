{
  description = "Reusable Nix flake for Pterodactyl Panel + Wings (based on pterodactyl.io docs)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosModules = {
        panel = import ./modules/panel.nix { inherit pkgs config; };
        wings = import ./modules/wings.nix { inherit pkgs config; };
      };

      packages = {
        panel = import ./packages/panel.nix { inherit pkgs; };
        wings = import ./packages/wings.nix { inherit pkgs; };
      };
    });
}
