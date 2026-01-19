{ flake }:
{ lib, config, pkgs, ... }:

let
  cfg = config.services.pterodactyl;

  flakePkgs = flake.outputs.packages.${pkgs.system};

  defaultUser = "pterodactyl";
in {
  options.services.pterodactyl = {
    enable = lib.mkEnableOption "Enable the pterodacytl game server panel";

    proxy = {
      enable = lib.mkEnableOption "Automatically configure Nginx to serve the panel";
      serverName = lib.mkOption {
        type = lib.types.str;
        description = "The canonical domain on which the panel will be hosted";
        default = "localhost";
        example = "pterodactyl.example.com";
      };

      listenAddresses = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "The addresses the nginx server should listen on";
        default = [ "127.0.0.1" "[::1]" ];
      };
    };

    user = lib.mkOption {
      type = lib.types.str;
      description = ''
        The user that owns the files managed by the panel.
        If you change this, make sure their files are accessible by your www user
        (probably "nginx").
      '';
      default = defaultUser;
      example = defaultUser;
    };

    pkg = lib.mkOption {
      type = lib.types.package;
      description = "The package in which to source the php files used by pterodactyl";
      default = flakePkgs.pterodactyl;
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      description = "The directory in which to store stateful data";
      default = "/var/lib/pterodactyl";
    };

    redis = {
      configureLocally = lib.mkEnableOption "Configure a local redis server for pterodactyl";

      name = lib.mkOption {
        type = lib.types.str;
        description = "The Redis server name.";
        default = "redis-pterodactyl";
      };

      port = lib.mkOption {
        type = lib.types.port;
        description = "The port the redis server listens on";
        default = 6379;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users = lib.mkIf (cfg.user == defaultUser) {
      users.${cfg.user} = {
        isSystemUser = true;
        createHome = true;
        home = cfg.dataDir;
        group = cfg.user;
      };

      groups.${cfg.user} = { };

      users.${config.services.nginx.user}.extraGroups = [ cfg.user ];
    };

    services.redis.servers.${cfg.redis.name} = lib.mkIf cfg.redis.configureLocally {
      enable = true;
      port = cfg.redis.port;
    };

    services.nginx = lib.mkIf cfg.proxy.enable {
      enable = true;

      virtualHosts."${cfg.proxy.serverName}" = {
        root = "${config.services.pterodactyl.pkg}/public";

        extraConfig = ''
          index index.html index.htm index.php;
        '';

        locations = {
          "~ \\.php$".extraConfig = ''
            include ${pkgs.nginx}/conf/fastcgi_params;

            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:${config.services.phpfpm.pools.pterodactyl.socket};

            fastcgi_index index.php;

            fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param HTTP_PROXY "";

            fastcgi_intercept_errors off;

            fastcgi_buffer_size 16k;
            fastcgi_buffers 4 16k;

            fastcgi_connect_timeout 300;
            fastcgi_send_timeout 300;
            fastcgi_read_timeout 300;
          '';

          "/" = {
            tryFiles = "$uri $uri/ /index.php?$query_string";
          };
        };
      };
    };

    services.phpfpm.pools.pterodactyl = {
      user = cfg.user;
      settings = {
        "listen.owner" = config.services.nginx.user;
        "pm" = "dynamic";
        "pm.start_servers" = 4;
        "pm.min_spare_servers" = 4;
        "pm.max_spare_servers" = 16;
        "pm.max_children" = 64;
        "pm.max_requests" = 256;

        "clear_env" = false;
        "catch_workers_output" = true;
        "decorate_workers_output" = false;
        "php_admin_value[error_log]" = "stderr";
        "php_admin_flag[daemonize]" = "false";
      };
    };

    systemd.services.pteroq = {
      enable = true;
      description = "Pterodactyl Queue Worker";
      after = [ "redis-${cfg.redis.name}.service" ];
      unitConfig = { StartLimitInterval = 180; };
      serviceConfig = {
        User = cfg.user;
        Group = cfg.user;
        Restart = "always";
        ExecStart =
          "${flakePkgs.php}/bin/php ${cfg.pkg}/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3";
        StartLimitBurst = 30;
        RestartSec = "5s";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
