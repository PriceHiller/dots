{
  config,
  pkgs,
  lib,
  ...
}:
let
  pg_dataDir_base = "/var/lib/postgresql";
in
{
  services.postgresqlBackup = {
    enable = true;
    location = "/var/backup/postgresql";
    backupAll = true;
  };

  services.postgresql = {
    enable = true;
    dataDir = "${pg_dataDir_base}/${config.services.postgresql.package.psqlSchema}";
    settings = {
      log_connections = true;
      log_disconnections = true;
      logging_collector = true;
      log_statement = "all";
      log_directory = "/var/log/postgresql/${config.services.postgresql.package.psqlSchema}/";
    };
    ensureUsers = [
      {
        name = "root";
        ensureClauses.superuser = true;
      }
    ];
  };

  systemd.services.postgresql.serviceConfig = {
    # Ensure postgres can write to its specified log directory
    ReadWritePaths = lib.mkBefore [
      config.services.postgresql.settings.log_directory
    ];
  };

  environment.systemPackages = [ pkgs.pgloader ];

  environment.persistence.save.directories = [
    {
      directory = "${pg_dataDir_base}";
      user = "postgres";
      group = "postgres";
    }
    {
      directory = config.services.postgresqlBackup.location;
      user = "postgres";
      group = "postgres";
    }
  ];
}
