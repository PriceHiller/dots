{ config, pkgs, ... }:
{
  programs.msmtp = {
    enable = true;
    defaults = {
      port = 465;
      tls = true;
      tls_starttls = false;
      aliases = pkgs.writeText "msmtp-aliases" ''
        default: monitoring@price-hiller.com
      '';
      allow_from_override = false;
    };
    accounts.default = {
      auth = true;
      host = "smtp.purelymail.com";
      from = "%U.%H@${config.networking.domain}";
      from_full_name = "${config.networking.hostName}";
      user = "monitoring@${config.networking.domain}";
      passwordeval = "${pkgs.coreutils}/bin/cat ${config.age.secrets.mail-pass.path}";
    };
  };
}