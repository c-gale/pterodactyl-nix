{ config, lib, pkgs, inputs, ... }:

let
  pteroPkg = inputs.pterodactyl.packages.${pkgs.system}.pterodactylPanel;
in

{
  options.services.pterodactyl = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Pterodactyl Panel on this machine.";
    };

    # You can extend this with database credentials, domain name, etc.
    panelDomain = lib.mkOption {
      type = lib.types.str;
      default = "pterodactyl.local";
      description = "Domain for the Pterodactyl panel.";
    };
  };

  config = lib.mkIf config.services.pterodactyl.enable {
    # Install the built panel
    environment.systemPackages = [ pteroPkg ];

    # Ensure php-fpm and nginx are enabled
    services.phpfpm.enable = true;
    services.phpfpm.pools."pterodactyl" = {
      user = "ptero";
      settings = {
        listen = "/run/php-fpm-pterodactyl.sock";
        php_admin_value[error_log] = "/var/log/pterodactyl/php-fpm-error.log";
      };
      phpEnv.PATH = lib.makeBinPath [ *pkgs.phpWithExtensions ];
    };

    services.nginx = {
      enable = true;
      virtualHosts."${config.services.pterodactyl.panelDomain}" = {
        root = "${pkgs.readShellScript ./set-root}/www"; # placeholder
        listen = [ { addr = "0.0.0.0"; port = 80; } ];
        phpFastCGI = "/run/php-fpm-pterodactyl.sock";
      };
    };

    # Deployment directory (so nginx can serve it)
    environment.etc = {
      "pterodactyl-panel".source = "${pteroPkg}/";
    };

    # Create service user
    users.users.ptero = {
      createHome = true;
      home = "/var/lib/pterodactyl";
      description = "Service user for Pterodactyl Panel";
      extraGroups = [ "nginx" ];
    };

    # Systemd service to run migrations & key generation once
    systemd.services.pterodactyl-init = {
      description = "Initial Pterodactyl config (run once)";
      serviceConfig = {
        ExecStart = ''
          export COMPOSER_ALLOW_SUPERUSER=1
          cd /etc/pterodactyl-panel
          cp .env.example .env || true
          php artisan key:generate --force
          php artisan migrate --force
        '';
        User = "ptero";
        Group = "ptero";
        Type = "oneshot";
        RemainAfterExit = true;
      };
      install.wantedBy = [ "multi-user.target" ];
    };

    # Optional: queue worker
    systemd.services.pterodactyl-queue = {
      description = "Pterodactyl Queue Worker";
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "php /etc/pterodactyl-panel/artisan queue:work --sleep=3 --tries=3 --timeout=90";
        Restart = "always";
        User = "ptero";
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Make sure firewall opens HTTP
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
