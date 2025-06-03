{
  pkgs,
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
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      dotDir = ".config/zsh-dotdir";
      enableCompletion = true;
      initContent =
        let
          zsh-cache-dir = "${config.xdg.cacheHome}/zsh";
        in
        lib.mkMerge [
          (builtins.readFile ./init-extra.zsh)
          "mkdir -p ${zsh-cache-dir} && autoload -Uz compinit && compinit -d ${zsh-cache-dir}/zcompdump-$ZSH_VERSION"
        ];
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      plugins = [
        {
          name = "nix-shell";
          src = "${pkgs.zsh-nix-shell.src}";
        }
        {
          name = pkgs.zsh-completions.pname;
          src = pkgs.zsh-completions.src;
        }
        {
          name = pkgs.nix-zsh-completions.pname;
          src = pkgs.nix-zsh-completions.src;
        }
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab.src}";
        }
      ];
      completionInit = "";
    };
  };
}
