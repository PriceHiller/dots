{ ... }:
let
  rustDeskDomain = "rustdesk.pricehiller.com";
in
{
  services = {
    rustdesk-server = {
      enable = true;
      openFirewall = true;
      relay.enable = true;
      signal = {
        enable = true;
        relayHosts = [
          rustDeskDomain
        ];
      };
    };
    nginx.virtualHosts.${rustDeskDomain} = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/ws/id" = {
          proxyPass = "http://127.0.0.1:21118";
          extraConfig =
            # nginx
            ''
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "Upgrade";
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_read_timeout 120s;
            '';
        };
        "/ws/relay" = {
          proxyPass = "http://127.0.0.1:21119";
          extraConfig =
            # nginx
            ''
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "Upgrade";
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_read_timeout 120s;
            '';
        };
      };
    };
  };
  environment.persistence.save = {
    directories = [
      {
        directory = "/var/lib/private/rustdesk";
        mode = "0700";
        user = "nobody";
        group = "nogroup";
      }
    ];
  };
}
