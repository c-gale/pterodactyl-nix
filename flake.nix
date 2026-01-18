{
  description = "Reusable Nix flake for Pterodactyl Panel + Wings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
    let pkgs = import nixpkgs { inherit system; };
    in {
      # Export the modules — *not* applying them with `config` here
      nixosModules = {
        pterodactyl-panel = ./modules/panel.nix;
        pterodactyl-wings = ./modules/wings.nix;
      };

      # Export the built packages
      packages = {
        panel = import ./packages/panel.nix { inherit pkgs; };
        wings = import ./packages/wings.nix { inherit pkgs; };
      };
    });
}
