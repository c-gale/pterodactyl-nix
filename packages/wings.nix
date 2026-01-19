{ pkgs }:
pkgs.goPackages.buildGoModule {
  pname = "wings";
  version = "latest";

  src = pkgs.fetchFromGitHub {
    owner = "pterodactyl";
    repo = "wings";
    rev = "3b968bbae1491e3922bb8b67912b30e462111cee";
    sha256 = "sha256-E5jD/IYkFXhhJyRRftCFjn8cq0QAX60s5Nbdw6zLYow=";
  };

  # Wings build may require specific flags
  vendorSha256 = null;
}
