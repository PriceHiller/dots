{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    fzf = {
      keybindings = true;
      fuzzyCompletion = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      syntaxHighlighting.enable = true;
      shellInit = ''
        source "${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh"
      '';
    };
  };

  system.userActivationScripts.zshrc = "touch .zshrc";

  environment.systemPackages = with pkgs; [
    vim
    coreutils-full
    nano
    curl
    wget
    git
    jq
    rsync
  ];
}
