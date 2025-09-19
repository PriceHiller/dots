{ pkgs, ... }:
{
  programs.go = {
    enable = true;
    env = {
      GOBIN = ".local/bin/go";
      GOPATH = ".local/share/go";
    };
    telemetry.mode = "off";
  };
  home.packages = with pkgs; [ (lib.hiPrio gotools) ];
}
