{ ... }:
{
  services.cliphist.enable = true;
  systemd.user.services.cliphist = {
    Service.RestartSec = 3;
    Install.WantedBy = [ "compositor.target" ];
    Unit = {
      PartOf = [ "compositor.target" ];
      After = [ "compositor.target" ];
    };
  };
}
