{ pkgs, ... }:
{
  home.packages = [ pkgs.thunderbird ];
  xdg = {
    desktopEntries.thunderbird = {
      name = "thunderbird";
      exec = "${pkgs.thunderbird}/bin/thunderbird";
    };
    mimeApps = {
      associations.added = {
        "x-scheme-handler/mailto" = [ "thunderbird.desktop " ];
        "text/calendar" = [ "thunderbird.desktop " ];
      };
      defaultApplications = {
        "x-scheme-handler/mailto" = [ "thunderbird.desktop " ];
        "text/calendar" = [ "thunderbird.desktop " ];
      };
    };
  };
}
