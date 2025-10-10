{ config, lib, ... }:
{
  ext.services.openssh.enable = true;
  services.openssh = {
    # We set the hostkeys manually so they persist through reboots
    hostKeys = [
      {
        path = (
          config.environment.persistence.ephemeral.persistentStoragePath + "/etc/ssh/ssh_host_ed25519_key"
        );
        type = "ed25519";
      }
    ];
    settings.PerSourcePenaltyExemptList = lib.strings.concatStringsSep "," [
      "192.168.0.0/22"
    ];
    ports = [ 2200 ];
  };
}
