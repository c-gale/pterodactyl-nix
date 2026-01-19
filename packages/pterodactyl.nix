{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "pterodactyl-panel";
  version = "1.12.0";

  src = pkgs.fetchFromGitHub {
    owner = "pterodactyl";
    repo = "panel";
    rev = "v${version}";
    sha256 = "sha256-8DthHZqlNisNeYGVM0Hsxa0ml4sfoM3v5fqAPhNZCrU=";
  };

  nativeBuildInputs = with pkgs; [
    php84Packages.composer

    nodejs_24
    nodePackages.pnpm
  ];

  buildInputs = with pkgs; [
    php
    openssl
  ];

  buildPhase = ''
    export COMPOSER_ALLOW_SUPERUSER=1
    composer install --no-dev --optimize-autoloader

    pnpm install
    pnpm run build
  '';

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

  meta = with pkgs.lib; {
    description = "Pterodactyl Panel (game server management panel)";
    license = licenses.mit;
    homepage = "https://pterodactyl.io/panel";
  };
}
