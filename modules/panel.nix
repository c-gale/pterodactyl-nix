{ config, pkgs, lib, ... }:

let
  panelDir = "/var/www/pterodactyl";
in {

  options.services.pterodactyl.panel = {
    enable = lib.mkEnableOption "Pterodactyl Panel";
    domain = lib.mkOption { type = lib.types.str; default = ""; };
    dbPassword = lib.mkOption { type = lib.types.str; default = ""; };
    adminUser = lib.mkOption { type = lib.types.str; default = "admin"; };
    adminEmail = lib.mkOption { type = lib.types.str; default = ""; };
    adminPass = lib.mkOption { type = lib.types.str; default = ""; };
  };

  config = lib.mkIf config.services.pterodactyl.panel.enable ({
    environment.systemPackages = with pkgs; [
      php php-fpm
      phpExtensions.openssl phpExtensions.mbstring phpExtensions.bcmath
      phpExtensions.xml phpExtensions.curl phpExtensions.zip
      nginx git unzip curl mariadb redis composer
    ];

    # Deploy panel files
    environment.etc."pterodactyl-panel".source = pkgs.panel;

    # Nginx config
    services.nginx.enable = true;
    services.nginx.virtualHosts."${config.services.pterodactyl.panel.domain}" = {
      root = "${panelDir}/public";
      phpFpm = true;
      forceSSL = true;
    };

    services.phpfpm.enable = true;

    # Database service for Panel
    services.mysql.enable = true;
    services.redis.enable = true;

    # Run composer & migrations once
    systemd.services.pterodactyl-install = {
      description = "Install Pterodactyl Panel";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = ''
        mkdir -p ${panelDir}
        cp -r /etc/pterodactyl-panel/* ${panelDir}/
        cd ${panelDir}

        # As per docs: Composer install & optimize
        composer install --no-dev --optimize-autoloader

        # Setup env (as per docs)
        cp .env.example .env
        sed -i "s/APP_URL=.*/APP_URL=https://${config.services.pterodactyl.panel.domain}/" .env
        sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${config.services.pterodactyl.panel.dbPassword}/" .env

        # Generate key & migrate
        php artisan key:generate --force
        php artisan migrate --seed --force

        # Create admin user
        php artisan p:user:make --email=${config.services.pterodactyl.panel.adminEmail} \
          --username=${config.services.pterodactyl.panel.adminUser} \
          --password=${config.services.pterodactyl.panel.adminPass}
      '';
      serviceConfig.Type = "oneshot";
    };
  });
}
