{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.meta.mail;
in
{
  options.meta.mail = {
    enable = lib.mkEnableOption "Enable send mail integration via MSMTP";
    group = lib.mkOption {
      description = "The group to use for mail users";
      default = "sendmail";
      type = lib.types.str;
    };
    mailDomain = lib.mkOption {
      description = "The mail domain to use";
      default = "monitoring.pricehiller.com";
      type = lib.types.str;
    };
    agenixPassAttr = lib.mkOption {
      description = "The agenix attribute to use, e.g. 'mail-pass' from 'config.age.secrets.mail-pass'";
      type = lib.types.str;
    };
  };

  config = lib.mkIf (cfg.enable) {
    users.groups."${cfg.group}" = {};
    age.secrets.${cfg.agenixPassAttr}.group = cfg.group;
    programs.msmtp = {
      enable = true;
      defaults = {
        port = 465;
        tls = true;
        syslog = "on";
        aliases = pkgs.writeText "msmtp-aliases" ''
          root: ${config.networking.hostName}@monitoring.pricehiller.com
        '';
      };
      accounts.default = {
        auth = true;
        host = "smtp.purelymail.com";
        from = "${config.networking.hostName}@${cfg.mail-domain}";
        from_full_name = "${config.networking.hostName}";
        user = "monitor@${cfg.mail-domain}";
        passwordeval = "${pkgs.coreutils}/bin/cat ${config.age.secrets.${cfg.agenixPassAttr}.path}";
      };
    };
  };
}
