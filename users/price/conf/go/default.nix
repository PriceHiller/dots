{ pkgs, ... }:
{
  programs.go = {
    enable = true;
    goBin = ".local/bin/go";
    goPath = ".local/share/go";
  };
  home.packages = with pkgs; [ (lib.hiPrio gotools) ];
}
