{
  config,
  lib,
  ...
}:
let
  cfg = config.ext.services.openssh;
in
{
  options.ext.services.openssh = {
    enable = lib.options.mkEnableOption "Enable OpenSSH server with some defaults enabled";
    rootAuthorizedKeys = lib.mkOption {
      description = "The default authorizedKeys to specify for the root user";
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOkWsSntg1ufF40cALcIBA7WZhiU/f0cncqq0pcp+DZY price@pricehiller.com"
      ];
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf (cfg.enable) {
    users.users.root.openssh.authorizedKeys.keys = cfg.rootAuthorizedKeys;
    services.openssh = {
      enable = true;
      startWhenNeeded = true;
      sftpFlags = [
        "-f AUTHPRIV"
        "-l INFO"
      ];
      authorizedKeysInHomedir = false;
      settings = {
        PasswordAuthentication = false;
        AuthenticationMethods = "publickey";
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
        X11Forwarding = false;
        AllowAgentForwarding = false;
        AllowStreamLocalForwarding = false;
        AllowUsers = [ "root" ];
      };
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
  };
}
