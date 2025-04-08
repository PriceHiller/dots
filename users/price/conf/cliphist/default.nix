{ ... }:
{
  services.cliphist.enable = true;
  systemd.user.services =
    let
      defaults = {
        Service.RestartSec = 3;
        Install.WantedBy = [ "graphical-session.target" ];
        Unit = {
          PartOf = [ "graphical-session.target" ];
        };
      };
    in
    {
      cliphist = defaults;
      cliphist-images = defaults;
    };
}
