{ lib, ... }:
{
  programs = {
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      initContent = lib.mkOrder 3000 (builtins.readFile ./override-zoxide-comp.zsh);
    };
  };
}
