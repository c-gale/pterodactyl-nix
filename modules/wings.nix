{ config, pkgs, lib, ... }:

let
  configPath = "/etc/pterodactyl/config.yml";
in {

  options.services.pterodactyl.wings = {
    enable = lib.mkEnableOption "Pterodactyl Wings";
    configYaml = lib.mkOption {
      type = lib.types.str;
      description = "Contents of wings config.yml generated from the panel UI.";
    };
  };

  config = lib.mkIf config.services.pterodactyl.wings.enable ({
    environment.etc."pterodactyl-wings-config".text = config.services.pterodactyl.wings.configYaml;

    environment.systemPackages = [ pkgs.wings ];

    systemd.services.wings = {
      enable = true;
      serviceConfig.ExecStart = "${pkgs.wings}/bin/wings -c ${configPath}";
      Restart = "on-failure";
    };
  });
}
