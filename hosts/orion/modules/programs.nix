{
  inputs,
  pkgs,
  config,
  ...
}:
{
  environment.sessionVariables = {
    DO_NOT_TRACK = 1;
  };
  programs = {
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
    dconf.enable = true;
    zsh = {
      enable = true;
      enableCompletion = true;
      enableGlobalCompInit = false;
      enableBashCompletion = true;
    };
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
    config.boot.kernelPackages.perf
  ];
}
