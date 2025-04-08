{ pkgs, ... }:
{
  services.envfs.enable = true;
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        sqlite
        stdenv.cc.cc
        glibc.static
        glibc
      ];
    };
  };
}
