{ ... }:
{
  programs = {
    dconf.enable = true;
    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
    };
    nix-ld.enable = true;
  };
}
