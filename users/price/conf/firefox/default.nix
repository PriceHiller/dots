{
  pkgs,
  lib,
  config,
  ...
}:
{
  xdg.mimeApps = lib.mkIf (config.programs.firefox.enable) {
    associations.added = {
      "x-scheme-handler/http" = [ "firefox-developer-edition.desktop" ];
      "x-scheme-handler/https" = [ "firefox-developer-edition.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox-developer-edition.desktop" ];
      "text/html" = [ "firefox-developer-edition.desktop" ];
      "application/x-extension-htm" = [ "firefox-developer-edition.desktop" ];
      "application/x-extension-html" = [ "firefox-developer-edition.desktop" ];
      "application/x-extension-shtml" = [ "firefox-developer-edition.desktop" ];
      "application/xhtml+xml" = [ "firefox-developer-edition.desktop" ];
      "application/x-extension-xhtml" = [ "firefox-developer-edition.desktop" ];
      "application/x-extension-xht" = [ "firefox-developer-edition.desktop" ];
    };
    defaultApplications = {
      "x-scheme-handler/http" = [ "firefox-developer-edition.desktop" ];
      "x-scheme-handler/https" = [ "firefox-developer-edition.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox-developer-edition.desktop" ];
      "text/html" = [ "firefox-developer-edition.desktop" ];
      "application/x-extension-htm" = [ "firefox-developer-edition.desktop" ];
      "application/x-extension-html" = [ "firefox-developer-edition.desktop" ];
      "application/x-extension-shtml" = [ "firefox-developer-edition.desktop" ];
      "application/xhtml+xml" = [ "firefox-developer-edition.desktop" ];
      "application/x-extension-xhtml" = [ "firefox-developer-edition.desktop" ];
      "application/x-extension-xht" = [ "firefox-developer-edition.desktop" ];
    };
  };
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition-bin;
  };
}
