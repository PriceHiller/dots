{ config, ... }:
{
  programs = {
    z-lua = {
      enable = true;
      options = [
        "enhanced"
        "once"
      ];
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      initExtra = builtins.readFile ./init-extra.zsh;
      completionInit =
        let
          zsh-cache-dir = "${config.xdg.cacheHome}/zsh";
        in
        "mkdir -p ${zsh-cache-dir} && autoload -U compinit && compinit -d ${zsh-cache-dir}/zcompdump-$ZSH_VERSION";
    };
  };
}
