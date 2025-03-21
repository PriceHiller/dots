{
  pkgs,
  config,
  lib,
  ...
}:
{
  home =
    let
      wineprefix-dir = "${config.xdg.dataHome}/wineprefixes";
    in
    {
      sessionVariables = {
        WINEPREFIX = "${wineprefix-dir}/default";
      };
      activation.init = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "${wineprefix-dir}"
      '';
      packages = with pkgs; [
        wineWowPackages.waylandFull
        winetricks
      ];
    };
}
