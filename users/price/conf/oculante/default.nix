{ pkgs, ... }:
{
  home.packages = with pkgs; [
    oculante
  ];
  xdg.mimeApps = {
    defaultApplications = {
      "image/png" = [ "oculante.desktop" ];
      "image/bmp" = [ "oculante.desktop" ];
      "image/jpeg" = [ "oculante.desktop" ];
    };
  };
}
