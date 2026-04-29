{ lib, ... }:
{
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
    extraConfig = lib.mkMerge [
      # This is done to ensure `SSH_AUTH_SOCK` is picked up from the user session -- useful for nix
      # invocations that look up submodules.
      #
      # See https://pricehiller.com/posts/private-git-submodule-authentication-and-nixos-rebuilds
      ''
        Defaults env_keep+=SSH_AUTH_SOCK
      ''
    ];
  };

  # See https://developers.yubico.com/pam-u2f/
  # See https://wiki.nixos.org/wiki/Yubikey#pam_u2f
  security.pam = {
    services = {
      sudo = {
        u2f = {
          enable = true;
          control = "sufficient";
        };
      };
    };
  };
}
