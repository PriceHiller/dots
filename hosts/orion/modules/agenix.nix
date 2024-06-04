{ config, ... }:
{
  age.identityPaths = [
    (config.environment.persistence.ephemeral.persistentStoragePath + "/ssh_host_ed25519_key")
  ];
}
