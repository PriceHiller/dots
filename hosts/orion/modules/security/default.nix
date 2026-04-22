{ pkgs, lib, ... }:
let
  cert-file = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
in
{
  security = {
    pki = {
      certificateFiles = [
        "${cert-file}"
      ];
    };
    sudo-rs = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = false;
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
  };
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.log_martions" = true;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.log_martions" = true;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
  };
}
