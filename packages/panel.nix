{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "pterodactyl-panel";
  version = "latest";

  src = pkgs.fetchFromGitHub {
    owner = "pterodactyl";
    repo = "panel";
    rev = "main";
    sha256 = pkgs.lib.fakeSha256;
  };

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';
}
