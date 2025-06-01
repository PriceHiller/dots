{ pkgs, ... }:
{
  programs.go = {
    enable = true;
    goBin = ".local/bin/go";
    goPath = ".local/share/go";
    telemetry.mode = "off";
  };
  home.packages = with pkgs; [ (lib.hiPrio gotools) ];
}
