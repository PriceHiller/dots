{ lib, ... }:
{
  ext.services.openssh.enable = true;
  services.openssh.authorizedKeysInHomedir = lib.mkForce true;
}
