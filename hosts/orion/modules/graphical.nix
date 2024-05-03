{ pkgs, ... }:
{
  services.displayManager.sddm = {
    wayland.enable = true;
    enable = true;
  };
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  xdg = {
    autostart.enable = true;
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal
        xdg-desktop-portal-gtk
      ];
    };
  };
  hardware.opengl.enable = true;
  services.spice-vdagentd.enable = true;
}
