{ pkgs }:

let
  version = "1.11.11";
in pkgs.fetchzip {
  url = "https://github.com/pterodactyl/panel/releases/download/v${ version }/panel.tar.gz";
  hash = "sha256-0nOHtReVUVXYQY/glS4x0gkbhetoXSWg4rRwOJlkcM8=";
  stripRoot = false;
}
