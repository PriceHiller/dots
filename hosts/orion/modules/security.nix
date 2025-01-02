{ ... }:
{
  security = {
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