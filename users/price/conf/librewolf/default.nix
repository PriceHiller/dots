{ config, lib, ... }:
let
  attrsToStringPath =
    attrs:
    let
      _attrsToStringPath =
        _parent:
        let
          parent = if isNull _parent then "" else "${_parent}.";
        in
        attrs:
        lib.attrsets.foldlAttrs (
          acc: _name:
          let
            name = "${parent}${_name}";
          in
          value:
          acc // (if builtins.isAttrs value then _attrsToStringPath name value else { "${name}" = value; })
        ) { } attrs;
    in
    _attrsToStringPath null attrs;
in
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
    settings = attrsToStringPath {
      webgl.disabled = false;
      privacy.clearOnShutdown = {
        history = false;
        downloads = false;
        cookies = false;
      };
      network = {
        cookie.lifetimePolicy = 0;
        trr = {
          mode = 3;
          uri = "https://dns.mullvad.net/dns-query";
          default_provider_uri = "https://dns10.quad9.net/dns-query";
          strict_native_fallback = false;
          retry_on_recoverable_errors = true;
          disable-heuristics = true;
          allow-rfc1918 = true;
        };
      };
    };
  };
}
