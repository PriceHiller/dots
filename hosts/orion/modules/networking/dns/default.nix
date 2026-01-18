{
  config,
  ...
}:
{
  ext.dns = {
    enable = true;
    doh = {
      privateKey = config.age.secrets.pki-local-key.path;
      publicKey = ./localhost.crt;
    };
  };

  services.dnscrypt-proxy.settings.monitoring_ui = {
    enabled = true;
    privacy_level = 0;
    enable_query_log = true;
    username = "";
    password = "";
    listen_address = "127.0.0.1:8080";
    max_query_log_entries = 100000;
    max_memory_mb = 128;
  };

  services.nginx.virtualHosts = {
    "dnscrypt.localhost" = {
      forceSSL = false;
      enableACME = false;
      locations."/" = {
        proxyPass = "http://${config.services.dnscrypt-proxy.settings.monitoring_ui.listen_address}/";
        proxyWebsockets = true;
      };
    };
  };

}
