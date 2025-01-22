{ config, lib, ... }:
{

  xdg.mimeApps.defaultApplications = lib.mkIf (config.programs.librewolf.enable) {
    defaultApplications = {
      "default-web-browser" = [ "librewolf.desktop" ];
      "text/html" = [ "librewolf.desktop" ];
      "x-scheme-handler/http" = [ "librewolf.desktop" ];
      "x-scheme-handler/https" = [ "librewolf.desktop" ];
      "x-scheme-handler/about" = [ "librewolf.desktop" ];
      "x-scheme-handler/unknown" = [ "librewolf.desktop" ];
    };
  };
  programs.librewolf = {
    enable = true;
    settings = {
      "webgl.disabled" = false;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "network.cookie.lifetimePolicy" = 0;
      "network.trr.mode" = 2;
      "network.trr.uri" = "https://dns.mullvad.net/dns-query";
      "network.trr.default_provider_uri" = "https://dns10.quad9.net/dns-query";
      "network.trr.strict_native_fallback" = false;
      "network.trr.retry_on_recoverable_errors" = true;
      "network.trr.disable-heuristics" = true;
      "network.trr.allow-rfc1918" = true;
    };
  };
}
