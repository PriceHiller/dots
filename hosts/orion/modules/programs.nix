{ pkgs, ... }:
{
  environment.sessionVariables = {
    DO_NOT_TRACK = 1;
  };
  programs = {
    hyprland.enable = true;
    dconf.enable = true;
    zsh = {
      enable = true;
      enableCompletion = true;
      enableGlobalCompInit = false;
      enableBashCompletion = true;
    };
    nix-ld.enable = true;
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
}