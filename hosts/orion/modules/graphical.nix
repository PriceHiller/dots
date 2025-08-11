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
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt
      intel-media-driver
      libvdpau
    ];
  };
}
