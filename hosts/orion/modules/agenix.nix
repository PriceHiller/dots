{ config, pkgs, ... }:
{
  age = {
    ageBin = "PATH=${pkgs.age-plugin-yubikey}/bin:$PATH ${pkgs.rage}/bin/rage";
    identityPaths = [
      (config.environment.persistence.ephemeral.persistentStoragePath + "/ssh_host_ed25519_key")
    ];
  };
}
