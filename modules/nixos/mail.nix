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
    host = lib.mkOption {
      description = "The mail smtp server host";
      default = "smtp.purelymail.com";
      type = lib.types.str;
    };
    port = lib.mkOption {
      description = "The port to send SMTP traffic on";
      default = 465;
      type = lib.types.port;
    };
    connectionString = lib.mkOption {
      description = "The full connection string of the host and port in the format `host:port`";
      default = "${cfg.host}:${builtins.toString cfg.port}";
      readOnly = true;
    };
    user = lib.mkOption {
      description = "The user used for authentication to the mail server";
      default = "monitor@${cfg.mailDomain}";
      type = lib.types.str;
    };
    passwordPath = lib.mkOption {
      description = "The path to the password file used for authentication to the mail server";
      default = config.age.secrets.${cfg.agenixPassAttr}.path;
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
        port = cfg.port;
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
        host = cfg.host;
        from = "%U.${config.networking.hostName}@${cfg.mailDomain}";
        from_full_name = "${config.networking.hostName}";
        user = cfg.user;
        passwordeval = "${pkgs.coreutils}/bin/cat ${cfg.passwordPath}";
      };
    };
  };
}
