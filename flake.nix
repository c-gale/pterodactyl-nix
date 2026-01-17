{
  description = "Nixos modules for the pterodactyl game server panel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ];
    in
    {
      # export modules under self.nixosModules
      nixosModules = nixpkgs.lib.genAttrs [ "pterodactyl" ] (module: 
        import ./modules/${module}.nix { inherit self nixpkgs; }
      );

      # export packages for each system
      packages = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        nixpkgs.lib.genAttrs [ "pterodactyl" "php" "wings" ] (pkg:
          import ./packages/${pkg}.nix { inherit pkgs; }
        )
      );
    };
}
