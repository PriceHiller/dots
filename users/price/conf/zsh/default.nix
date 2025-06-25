{
  pkgs,
  config,
  lib,
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
      enableCompletion = true;
      completionInit = # zsh
        ''
          autoload -Uz compinit && compinit
          autoload -Uz +X bashcompinit && bashcompinit
        '';
      initContent = lib.mkMerge [
        (
          # The lib.mkOrder here ensures `fzf-tab` loads _right_ after completion init occurs
          lib.mkOrder 571 ''source "${pkgs.zsh-fzf-tab.src}/fzf-tab.plugin.zsh"''
        )
        (builtins.readFile ./init-extra.zsh)
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
      ];
    };
  };
}
