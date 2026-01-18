{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "pterodactyl-panel";
  version = "1.12.0";

  src = pkgs.fetchFromGitHub {
    owner = "pterodactyl";
    repo = "panel";
    rev = "v${version}";
    sha256 = lib.fakeSha256;
  };

  nativeBuildInputs = with pkgs; [
    php84Packages.composer

    nodejs_24
    nodePackages.pnpm
  ];

  buildInputs = with pkgs; [

    php
    phpPackages.cli
    phpPackages.openssl
    phpPackages.gd
    phpPackages.mysql
    phpPackages.pdo
    phpPackages.mbstring
    phpPackages.tokenizer
    phpPackages.bcmath
    phpPackages.xml
    phpPackages.curl
    phpPackages.zip
    phpPackages.fpm
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
