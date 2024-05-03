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
    settings = {
      PasswordAuthentication = false;
      AuthenticationMethods = "publickey";
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
      AllowAgentForwarding = false;
      AllowStreamLocalForwarding = false;
      LogLevel = "VERBOSE";
      AllowUsers = [ "price" ];
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
