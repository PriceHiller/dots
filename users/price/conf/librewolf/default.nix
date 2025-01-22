{ config, lib, ... }:
{

  xdg.mimeApps.defaultApplications = lib.mkIf (config.programs.librewolf.enable) {
    "default-web-browser" = [ "librewolf.desktop" ];
    "text/html" = [ "librewolf.desktop" ];
    "x-scheme-handler/http" = [ "librewolf.desktop" ];
    "x-scheme-handler/https" = [ "librewolf.desktop" ];
    "x-scheme-handler/about" = [ "librewolf.desktop" ];
    "x-scheme-handler/unknown" = [ "librewolf.desktop" ];
    "x-scheme-handler/chrome" = [ "librewolf.desktop" ];
    "application/x-extension-htm" = [ "librewolf.desktop" ];
    "application/x-extension-html" = [ "librewolf.desktop" ];
    "application/x-extension-shtml" = [ "librewolf.desktop" ];
    "application/xhtml+xml" = [ "librewolf.desktop" ];
    "application/x-extension-xhtml" = [ "librewolf.desktop" ];
    "application/x-extension-xht" = [ "librewolf.desktop" ];
  };
  programs.librewolf = {
    enable = true;
    settings = {
      "webgl.disabled" = false;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.downloads" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "network.cookie.lifetimePolicy" = 0;
      "network.trr.mode" = 3;
      "network.trr.uri" = "https://dns.mullvad.net/dns-query";
      "network.trr.default_provider_uri" = "https://dns10.quad9.net/dns-query";
      "network.trr.strict_native_fallback" = false;
      "network.trr.retry_on_recoverable_errors" = true;
      "network.trr.disable-heuristics" = true;
      "network.trr.allow-rfc1918" = true;
    };
  };
}
