{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  ext.basePrograms = {
    enable = true;
    zsh.enableFzfTab = false;
  };
  programs = {
    zsh.enableGlobalCompInit = lib.mkForce false;
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
    dconf.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    steam.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
  };
  environment.systemPackages = [
    pkgs.perf
  ];
}