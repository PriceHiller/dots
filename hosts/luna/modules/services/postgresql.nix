{ config, pkgs, ... }:
{
  services.postgresqlBackup = {
    location = "/var/backup/postgresql";
    backupAll = true;
  };
  services.postgresql = {
    enable = true;
    # Explicitly setting the data dir so upgrades (changing version from 15 -> 16) don't end up
    # getting lost on system reboots
    dataDir = "/var/lib/postgresql";
    settings = {
      log_connections = true;
      log_disconnections = true;
      logging_collector = true;
      log_statement = "all";
    };
    ensureUsers = [
      {
        name = "root";
        ensureClauses.superuser = true;
      }
    ];
  };

  environment.systemPackages = [ pkgs.pgloader ];

  environment.persistence.save.directories = [
    {
      directory = config.services.postgresql.dataDir;
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
