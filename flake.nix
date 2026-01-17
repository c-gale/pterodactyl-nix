{
  description = "Nixos modules for the pterodactyl game server panel";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules = nixpkgs.lib.genAttrs [ "pterodactyl" ] (
      module: import ./modules/${module}.nix { flake = self; }
    );

    packages = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (
      system: nixpkgs.lib.genAttrs [ "pterodactyl" "php" "wings" ] (
        package: import ./packages/${package}.nix { pkgs = import nixpkgs { inherit system; }; };
      )
    });
  };
}
