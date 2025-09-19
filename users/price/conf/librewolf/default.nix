{
  config,
  lib,
  clib,
  ...
}:
let
  nixValToLibrewolfPref =
    val:
    if builtins.isList val then
      "[${val |> builtins.map (item: ''"${item}"'') |> lib.strings.concatStringsSep ","}]"
    else
      val;

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
    settings = clib.attrsToMozillaPref {
      identity.fxaccounts.enabled = true;
      webgl.disabled = false;
      browser.policies.runOncePerModification = {
        extensionsInstall = [ ];
        removeSearchEngines = [
          "Bing"
          "Amazon.com"
          "eBay"
          "Twitter"
        ];
        extensionsUninstall = [
          "bing@search.mozilla.org"
          "amazondotcom@search.mozilla.org"
          "ebay@search.mozilla.org"
          "twitter@search.mozilla.org"
        ];
      };
      privacy = {
        # Disabled for now, causes too many issues for me unfortunately :(
        # In the future investigate compat with surfing keys and resistFingerprinting
        resistFingerprinting = false;
        clearOnShutdown = {
          history = false;
          downloads = false;
          cookies = false;
        };
      };
      sidebar = {
        main.tools = "syncedtabs,history,bookmarks";
        verticalTabs = true;
        revamp = true;
      };
      font = {
        default.x-western = "sans-serif";
        minimum-size.x-western = 18;
      };
      network = {
        cookie.lifetimePolicy = 0;
        # We use the local DNS resolver, it should support encryption
        trr.mode = 0;
      };
    };
  };
}
