{
  config,
  ...
}:
{
  age.secrets.nginx-basic-auth = {
    owner = config.services.nginx.user;
    group = config.services.nginx.user;
  };

  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;
  };

  environment.persistence.ephemeral.directories =
    let
      acmeCfg = config.security.acme;
      acmeUser = if acmeCfg.useRoot then "root" else "acme";
      acmeGroup = acmeCfg.defaults.group;
    in
    builtins.concatLists [
      [
        {
          directory = "/var/lib/acme";
          user = acmeUser;
          group = acmeGroup;
        }
      ]
      (
        acmeCfg.certs
        |> builtins.mapAttrs (
          _: val: {
            directory = val.directory;
            user = acmeUser;
            group = val.group;
            mode = "u=rwx,g=rx,o=";
          }
        )
        |> builtins.attrValues
      )
    ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  environment.etc = {
    "fail2ban/filter.d/nginx-unauthorized.conf".text = ''
      [Definition]
      failregex = ^\{.*"status":40(1|3),.*"remote_addr":"<HOST>".*\}$
      ignoreregex =
    '';

    "fail2ban/filter.d/nginx-direct-ip-access.conf".text = ''
      [Definition]
      failregex = ^\{.*"http_host":"\d+\.\d+\.\d+\.\d+.*?",.*"remote_addr":"<HOST>".*\}$
      ignoreregex =
    '';

    "fail2ban/filter.d/nginx-404s.conf".text = ''
      [Definition]
      failregex = ^\{.*"status":404,.*"remote_addr":"<HOST>".*\}$
      ignoreregex =
    '';

    "fail2ban/filter.d/nginx-empty-user-agent.conf".text = ''
      [Definition]
      failregex = ^\{.*"http_user_agent":"\s*"\,.*"remote_addr":"<HOST>".*\}$
      ignoreregex =
    '';
  };

  services.fail2ban = {
    enable = true;
    bantime-increment = {
      enable = true;
      overalljails = true;
    };
    ignoreIP = [
      "192.168.0.0/16"
      "127.0.0.1/8"
      "::1"
    ];
    jails = {
      nginx-too-many-404s.settings = {
        enabled = true;
        filter = "nginx-404s";
        logpath = "/var/log/nginx/access.log";
        backend = "auto";
        maxretry = 5;
        findtime = "30m";
        bantime = "10m";
      };
      nginx-direct-ip-access.settings = {
        enabled = true;
        filter = "nginx-direct-ip-access";
        logpath = "/var/log/nginx/access.log";
        backend = "auto";
        maxretry = 2;
        findtime = "5m";
        bantime = "5m";
      };
      nginx-unauthorized.settings = {
        enabled = true;
        filter = "nginx-unauthorized";
        logpath = "/var/log/nginx/access.log";
        backend = "auto";
        maxretry = 3;
        findtime = "1h";
        bantime = "30m";
      };
      nginx-empty-user-agent.settings = {
        enabled = true;
        filter = "nginx-empty-user-agent";
        logpath = "/var/log/nginx/access.log";
        backend = "auto";
        maxretry = 1;
        findtime = "30m";
        bantime = "5m";
      };
    };
  };

}
