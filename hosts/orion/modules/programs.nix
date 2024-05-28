{ ... }:
{
  programs = {
    dconf.enable = true;
    zsh = {
      enable = true;
      enableGlobalCompInit = false;
    };
    nix-ld.enable = true;
  };
}
