{ ... }:
{
  services.udiskie.enable = true;
  # Udiskie requires a tray target
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [
        "graphical-session-pre.target"
        "compositor.target"
      ];
    };
  };
}
