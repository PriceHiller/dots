{ config, ... }:
{
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    # We set the hostkeys manually so they persist through reboots
    hostKeys = [
      {
        path = (
          config.environment.persistence.ephemeral.persistentStoragePath + "/etc/ssh/ssh_host_ed25519_key"
        );
        type = "ed25519";
      }
    ];
    sftpFlags = [
      "-f AUTHPRIV"
      "-l INFO"
    ];
    extraConfig = ''
      AllowUsers price
    '';
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      GatewayPorts = "yes";
      LogLevel = "VERBOSE";
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group-exchange-sha256"
      ];
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
        "aes256-ctr"
        "aes192-ctr"
        "aes128-ctr"
      ];
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
    };
    ports = [ 2200 ];
    banner = ''
      ┌────────────────────────────────────────────────────┐
      │        Orion Technologies - Security Notice        │
      │        ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄        │
      │  UNAUTHORIZED ACCESS TO THIS DEVICE IS PROHIBITED  │
      │                                                    │
      │     You must have written, explicit, authorized    │
      │   permission to access or configure this device.   │
      │ Unauthorized attempts and actions to access or use │
      │   this system may result in civil and/or criminal  │
      │ penalties. All activities performed on this device │
      │              are logged and monitored.             │
      └────────────────────────────────────────────────────┘
    '';
  };
}
