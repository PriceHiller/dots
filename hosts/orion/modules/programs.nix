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
    gamescope.enable = true;
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      protontricks.enable = true;
      extraPackages = with pkgs; [
        steamcmd
        protonup-qt
      ];
    };
    appimage = {
      enable = true;
      binfmt = true;
    };
  };
  environment.systemPackages = with pkgs; [
    wineWow64Packages.stagingFull
    winetricks
    protonup-qt
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
