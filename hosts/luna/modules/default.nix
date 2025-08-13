{ ... }:

{
  time.timeZone = "America/Chicago";
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };
}