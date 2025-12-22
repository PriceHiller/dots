{ config, lib, ... }:
let
  baseDomain = "pricehiller.com";
in
{
  config = {
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "acme@monitoring.pricehiller.com";
        dnsProvider = "route53";
        environmentFile = config.age.secrets.acme-env-file.path;
      };
      certs = {
        ${baseDomain} = {
          domain = "${baseDomain}";
          extraDomainNames = [ "*.${baseDomain}" ];
          group = "nginx";
          reloadServices = [
            "nginx"
          ];
        };
      };
    };
  };

  # This allows the use of a wildcard certificate for ALL the hosts that fall under the base domain
  # or are the base domain. This means those subdomains don't end up in CT logs which get scraped by
  # everyone and end up with me starting a service and seeing immediate unwanted scrapes. They gotta
  # at least scrape my repo.
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          config = lib.mkIf (name == "${baseDomain}" || lib.strings.hasSuffix ".${baseDomain}" name) {
            useACMEHost = "${baseDomain}";
            locations."/.well-known".root = config.security.acme.certs.${baseDomain}.directory;
            enableACME = lib.mkDefault false;
          };
        }
      )
    );
  };
}
