{ pkgs, ... }:
{
  # Allow Chromium & Electron apps run natively in wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    NIXOS_WAYLAND = "1";
  };
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
  };
  security.pam.services.hyprlock = { };
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };
  hardware.nvidia.primeBatterySaverSpecialisation = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt
      intel-media-driver
      libvdpau
      nvidia-vaapi-driver
    ];
  };
}
