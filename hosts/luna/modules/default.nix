{ ... }:

{
  time.timeZone = "America/Chicago";
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';
}
