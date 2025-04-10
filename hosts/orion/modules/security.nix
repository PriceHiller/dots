{ pkgs, ... }:
let
  cert-file = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
in
{
  environment.sessionVariables = {
    NIX_SSL_CERT_FILE = "${cert-file}";
    SSL_CERT_FILE = "${cert-file}";
  };
  security = {
    pki = {
      certificateFiles = [
        "${cert-file}"
      ];
    };
    polkit = {
      enable = true;
    };
    sudo.execWheelOnly = true;
  };
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.log_martions" = true;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.log_martions" = true;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
  };
}
