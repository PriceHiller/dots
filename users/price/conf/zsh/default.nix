{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  ZSH-CACHE = "${config.xdg.cacheHome}/zsh";
in
{
  home = {
    file."${ZSH-CACHE}/.hm-create" = {
      text = ''
        Created by hm to ensure `${ZSH-CACHE}` exists.

        Do NOT edit!
      '';
      force = true;
    };
  };

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
      enableCompletion = false;
      initContent = lib.mkMerge [
        (builtins.readFile ./init-extra.zsh)
        # Init completions LAST
        # zsh
        ''
          autoload -Uz compinit && compinit
          autoload -Uz bashcompinit && bashcompinit
        ''
        # Ensure we load fzf-tab AFTER compinit
        # zsh
        ''source "${pkgs.zsh-fzf-tab.src}/fzf-tab.plugin.zsh"''
      ];
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      plugins = [
        {
          name = "nix-shell";
          src = "${pkgs.zsh-nix-shell.src}";
        }
        {
          name = "zsh-completions";
          src = "${inputs.zsh-completions}";
        }
        {
          name = pkgs.nix-zsh-completions.pname;
          src = pkgs.nix-zsh-completions.src;
        }
      ];
    };
  };
}
