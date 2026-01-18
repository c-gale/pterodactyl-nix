{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "pterodactyl-wings";
  version = "latest";

  src = pkgs.fetchFromGitHub {
    owner = "pterodactyl";
    repo = "wings";
    rev = "main";
    sha256 = pkgs.lib.fakeSha256;
  };

  nativeBuildInputs = [ pkgs.go ];

  buildPhase = ''
    export GOPATH=$(pwd)/.gopath
    mkdir -p $GOPATH/src/github.com/pterodactyl
    cp -r * $GOPATH/src/github.com/pterodactyl/wings
    cd $GOPATH/src/github.com/pterodactyl/wings
    go build -o wings .
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp wings $out/bin/
  '';
}
