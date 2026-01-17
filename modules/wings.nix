{ flake }:
{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.services.wings;

  flakePkgs = flake.outputs.packages.${pkgs.system};

  wings = cfg.pkg;
in {
  options.services.wings = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    configuration = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };

    version = lib.mkOption {
      type = lib.types.str;
      default = "latest";
    };

    pkg = lib.lib.mkOption {
      type = lib.types.package;
      description = "The package to use for the pterodactyl wings daemon";
      default = flakePkgs.wings;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;

    systemd.services.wings = {
      enable = cfg.enable;
      description = "Pterodactyl Wings daemon";

      after = [ "docker.service" ];
      partOf = [ "docker.service" ];
      requires = [ "docker.service" ];

      startLimitIntervalSec = 180;
      startLimitBurst = 30;

      serviceConfig = {
        User = "root";
        # WorkingDirectory = "/run/wings";

        LimitNOFILE = 4096;
        PIDFile = "/var/run/wings/daemon.pid";

        ExecStart = "${cfg.pkg}/bin/wings --config ${pkgs.writeText "config.yaml" (lib.strings.toJSON cfg.configuration)}";

        Restart = "on-failure";
        RestartSec = "5s";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
