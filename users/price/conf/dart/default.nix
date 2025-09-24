{
  pkgs,
  config,
  ...
}:
let
  dartDataHome = "${config.xdg.dataHome}/dart";
in
{
  home = {
    sessionVariables = {
      PUB_CACHE = "${config.xdg.cacheHome}/dart/pub-cache";
      ANALYZER_STATE_LOCATION_OVERRIDE = "${config.xdg.cacheHome}/dart/server";
      DATA_DART_HOME = dartDataHome;
    };
    packages = [
      pkgs.flutter
    ];
  };
}
