{
  description = "Reusable Pterodactyl Panel + Wings flake (NixOS modules + packages)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: let
    systems = [ "x86_64-linux" "aarch64-linux" ];
  in flake-utils.lib.eachSystem systems (system: let
    pkgs = import nixpkgs { inherit system; };
  in {
    # NixOS modules that users can import
    nixosModules = {
      pterodactyl-panel = import ./modules/panel.nix { inherit pkgs config; };
      pterodactyl-wings = import ./modules/wings.nix { inherit pkgs config; };
    };

    # Packages you might want to use directly
    packages = {
      panel = import ./packages/panel.nix { inherit pkgs; };
      wings = import ./packages/wings.nix { inherit pkgs; };
    };
  });
}
