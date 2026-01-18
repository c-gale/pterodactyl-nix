{ config, pkgs, lib, ... }:

with lib;

let
  panelDir = "/var/lib/pterodactyl/panel";
in {
  options.services.pterodactyl.panel = {
    enable = mkEnableOption "Pterodactyl Panel";
    domain = mkOption {
      type = types.str;
      default = "panel.local";
    };
    secret = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = mkIf config.services.pterodactyl.panel.enable ({
    environment.systemPackages = [ pkgs.php pkgs.nginx pkgs.redis pkgs.mariadb ];

    # Pull built panel package
    environment.etc."pterodactyl-panel".source = "${pkgs.panel}";

    services.nginx.enable = true;
    services.nginx.virtualHosts."${config.services.pterodactyl.panel.domain}" = {
      root = "${panelDir}/public";
      phpFpm = true;
    };
  });
}
