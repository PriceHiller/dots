{ pkgs, ... }:
{
  # Allow Chromium & Electron apps run natively in wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "price";
    };
    defaultSession = "hyprland";
    sddm = {
      wayland.enable = true;
      enable = true;
      autoLogin.relogin = true;
    };
  };
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  xdg = {
    autostart.enable = true;
    portal.enable = true;
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau
    ];
  };
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}