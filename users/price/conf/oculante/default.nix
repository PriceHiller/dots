{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Waiting on https://github.com/NixOS/nixpkgs/pull/476565
    # oculante
  ];
  xdg.mimeApps = {
    defaultApplications = {
      "image/png" = [ "oculante.desktop" ];
      "image/bmp" = [ "oculante.desktop" ];
      "image/jpeg" = [ "oculante.desktop" ];
    };
  };
}
