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

}
