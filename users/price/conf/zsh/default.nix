{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = builtins.readFile ./init-extra.zsh;
  };
}
