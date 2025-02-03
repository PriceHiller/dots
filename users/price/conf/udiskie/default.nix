{ ... }:
{
  services.udiskie.enable = true;
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      BindsTo = [
        "graphical-session-pre.target"
      ];
    };
  };
}
