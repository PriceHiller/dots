{ pkgs, ... }:
{
  programs = {
    dconf.enable = true;
    zsh = {
      enable = true;
      enableCompletion = true;
      enableGlobalCompInit = false;
      enableBashCompletion = true;
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
      ];
    };
    steam.enable = true;
  };
}
