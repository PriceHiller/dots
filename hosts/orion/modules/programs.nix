{
  inputs,
  pkgs,
  ...
}:
{
  ext.basePrograms.enable = true;
  programs = {
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
  environment.systemPackages = with pkgs; [
    perf
    via
    qmk
  ];
  hardware.keyboard.qmk.enable = true;
  services.udev.packages = with pkgs; [
    qmk
    qmk-udev-rules
    qmk_hid
    via
  ];
}
