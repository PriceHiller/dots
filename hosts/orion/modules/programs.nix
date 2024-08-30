{ ... }:
{
  programs = {
    dconf.enable = true;
    zsh = {
      enable = true;
      enableCompletion = true;
      enableGlobalCompInit = false;
      enableBashCompletion = true;
    };
    nix-ld.enable = true;
    steam.enable = true;
  };
}
