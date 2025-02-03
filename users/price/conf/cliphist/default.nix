{ ... }:
{
  services.cliphist.enable = true;
  systemd.user.services.cliphist = {
    Service.RestartSec = 3;
    Install.WantedBy = [ "graphical-session.target" ];
    Unit = {
      PartOf = [ "graphical-session.target" ];
    };
  };
}
