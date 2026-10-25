{ pkgs, config, ... }:
{
  programs.go = {
    enable = true;
    package = pkgs.go_latest;
    env = {
      GOBIN = "${config.home.homeDirectory}/.local/bin/go";
      GOPATH = "${config.home.homeDirectory}/.local/share/go";
      CC = "clang";
    };
    telemetry.mode = "off";
  };
  home.packages = with pkgs; [ (lib.hiPrio gotools) ];
}
