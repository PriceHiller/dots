{ config, ... }:
let
  vaultwardenCfg = config.services.vaultwarden;
in
{
  services.vaultwarden = {
    enable = true;
    configureNginx = true;
    domain = "vaultwarden.pricehiller.com";
    environmentFile = config.age.secrets.vaultwarden-env-file.path;
    config = {
      DOMAIN = "https://${vaultwardenCfg.domain}";
      WEBSOCKET_ENABLED = true;
      WEBSOCKET_ADDRESS = "127.0.0.1";
      WEBSOCKET_PORT = 3012;

      SMTP_FROM = "vaultwarden@${config.networking.domain}";
      SMTP_FROM_NAME = "Vaultwarden";
      USE_SENDMAIL = true;
      SENDMAIL_COMMAND = "${config.security.wrapperDir}/sendmail";
      SIGNUPS_ALLOWED = false;
    };
  };

  users.users.vaultwarden = {
    extraGroups = [
      config.meta.mail.group
    ];
  };
}
