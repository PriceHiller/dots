{
  config,
  lib,
  ...
}:
{
  programs = {
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh-dotdir";
      enableCompletion = false;
      initContent = lib.mkMerge [
        "export _ZO_DOCTOR=0"
        (builtins.readFile ./init-extra.zsh)
      ];
    };
  };
}
