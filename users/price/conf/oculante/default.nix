{ pkgs, clib, ... }:
{
  home.packages = with pkgs; [
    oculante
  ];
  xdg.mimeApps = {
    defaultApplications = clib.getMimeDefaults pkgs.oculante "oculante.desktop";
  };
}
