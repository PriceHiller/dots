{
  config,
  lib,
  ...
}:
let
  pg_dataDir_base = "/var/lib/postgresql";
in
{
  services.postgresqlBackup = {
    enable = true;
    location = "/var/backup/postgresql/${config.services.postgresql.package.psqlSchema}/";
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
    ReadWritePaths = lib.mkAfter [
      config.services.postgresql.settings.log_directory
    ];
  };

  environment.persistence.ephemeral.directories = [
    {
      directory = "${config.services.postgresql.settings.log_directory}";
      user = "postgres";
      group = "postgres";
      mode = "0770";
    }
  ];

  environment.persistence.save.directories = [
    {
      directory = "${pg_dataDir_base}";
      user = "postgres";
      group = "postgres";
      mode = "0770";
    }
    {
      directory = config.services.postgresqlBackup.location;
      user = "postgres";
      group = "postgres";
      mode = "0770";
    }
  ];
}
