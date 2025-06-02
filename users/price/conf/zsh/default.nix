{ pkgs, config, ... }:
{
  programs = {
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      dotDir = ".config/zsh-dotdir";
      enableCompletion = true;
      initContent = builtins.readFile ./init-extra.zsh;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      plugins = [
        {
          name = "zsh-completions";
          src = "${pkgs.zsh-completions}/share/zsh-completions";
        }
        {
          name = "nix-zsh-completions";
          src = "${pkgs.nix-zsh-completions}/share/nix-zsh-completions";
        }
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
      ];
      completionInit =
        let
          zsh-cache-dir = "${config.xdg.cacheHome}/zsh";
        in
        "mkdir -p ${zsh-cache-dir} && autoload -U compinit && compinit -u -d ${zsh-cache-dir}/zcompdump-$ZSH_VERSION";
    };
  };
}
