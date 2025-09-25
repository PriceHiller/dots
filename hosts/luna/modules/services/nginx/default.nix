{
  inputs,
  config,
  pkgs,
  ...
}:
{
  age.secrets.nginx-basic-auth = {
    owner = config.services.nginx.user;
    group = config.services.nginx.user;
  };
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;
    appendHttpConfig = ''
      log_format logger-json escape=json '${
        # We remove the whitespace in the json log to ensure the json log comes out on a single line
        # in the system log
        builtins.replaceStrings [ "\n" " " ] [ "" "" ] ''
          {
              "time": "$time_iso8601",
              "time_msec": $msec,
              "status": $status,
              "http_user_agent": "$http_user_agent",
              "http_host": "$http_host",
              "http_referer": "$http_referer",
              "bytes_sent": $bytes_sent,
              "content_type": "$content_type",
              "content_length": "$content_length",
              "remote_addr": "$remote_addr",
              "request_length": $request_length,
              "request_method": "$request_method",
              "reqest_uri": "$request_uri",
              "request_time": $request_time,
              "server_protocol": "$server_protocol",
              "upstream_addr": "$upstream_addr"
          }
        ''
      }';
      access_log /var/log/nginx/access.log logger-json;
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@monitoring.pricehiller.com";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.nginx.virtualHosts = {
    "pricehiller.com" = {
      serverAliases = [
        "price-hiller.com"
      ];
      forceSSL = true;
      enableACME = true;
      root = inputs.blog.packages.${pkgs.system}.default;
      locations =
        let
          wkd-default-cfg = ''
            default_type "application/octet-stream";
            add_header Access-Control-Allow-Origin * always;
            add_header Last-Modified "";
          '';
        in
        {
          "/" = {
            extraConfig = ''
              if ($request_uri ~ ^/(.*)\.html(\?|$)) {
                  return 302 /$1;
              }
              try_files $uri $uri.html $uri/ =404;
            '';
          };
          "^~ /.well-known/openpgpkey/hu/" = {
            alias = "${./gpg-wkd}/$1";
            extraConfig = wkd-default-cfg;
          };
          "^~ /.well-known/openpgpkey/policy/hu/" = {
            alias = "${./gpg-wkd}/$1";
            extraConfig = wkd-default-cfg;
          };
          "= /.well-known/openpgpkey/policy" = {
            extraConfig = wkd-default-cfg;
            return = "200";
          };
        };
    };
  };
}
