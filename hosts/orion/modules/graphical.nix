{ inputs, pkgs, ... }:
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
    # set the flake package
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
  xdg.autostart.enable = true;
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
