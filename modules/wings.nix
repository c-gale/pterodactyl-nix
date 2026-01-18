{ config, pkgs, lib, ... }:

with lib;

let
  wingsDir = "/var/lib/pterodactyl/wings";
in {
  options.services.pterodactyl.wings = {
    enable = mkEnableOption "Pterodactyl Wings";
    nodeFQDN = mkOption { type = types.str; default = ""; };
  };

  config = mkIf config.services.pterodactyl.wings.enable ({
    environment.systemPackages = [ pkgs.wings ];

    systemd.services.wings = {
      enable = true;
      serviceConfig = {
        ExecStart = "${pkgs.wings}/bin/wings --config /etc/pterodactyl/wings.yml";
        Restart = "on-failure";
      };
    };
  });
}
