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
    users.groups."${cfg.group}" = { };
    age.secrets.${cfg.agenixPassAttr} = {
      group = cfg.group;
      mode = "0440";
    };
    programs.msmtp = {
      enable = true;
      defaults = {
        port = 465;
        tls = true;
        tls_starttls = false;
        syslog = "on";
        aliases = pkgs.writeText "msmtp-aliases" ''
          root: root.${config.networking.hostName}@${cfg.mailDomain}
          default: root
        '';
      };
      accounts.default = {
        auth = true;
        host = "smtp.purelymail.com";
        from = "%U.${config.networking.hostName}@${cfg.mailDomain}";
        from_full_name = "${config.networking.hostName}";
        user = "monitor@${cfg.mailDomain}";
        passwordeval = "${pkgs.coreutils}/bin/cat ${config.age.secrets.${cfg.agenixPassAttr}.path}";
      };
    };
  };
}
