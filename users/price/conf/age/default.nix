{ pkgs, lib, ... }:
{
  systemd.user.services.agenix = {
    Service = {
      Environment = "PATH=${
        lib.makeBinPath [
          pkgs.age
          pkgs.age-plugin-yubikey
        ]
      }";
    };
  };
}
