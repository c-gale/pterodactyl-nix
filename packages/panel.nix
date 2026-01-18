{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "pterodactyl-panel";
  version = "main";

  src = pkgs.fetchFromGitHub {
    owner = "pterodactyl";
    repo = "panel";
    rev = "main";
    sha256 = lib.fakeSha256;
  };

  buildPhase = "true";
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
