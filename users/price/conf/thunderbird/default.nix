{ pkgs, ... }:
{
  home.packages = [ pkgs.thunderbird ];
  xdg = {
    desktopEntries.thunderbird = {
      name = "thunderbird";
      exec = "${pkgs.thunderbird}/bin/thunderbird";
      icon = "${pkgs.thunderbird}/share/icons/hicolor/128x128/apps/thunderbird.png";
    };
    mimeApps = {
      associations.added = {
        "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
        "text/calendar" = [ "thunderbird.desktop" ];
      };
      defaultApplications = {
        "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
        "text/calendar" = [ "thunderbird.desktop" ];
      };
    };
  };
}
