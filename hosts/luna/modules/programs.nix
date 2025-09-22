{ pkgs, ... }:
{
  environment.sessionVariables = {
    DO_NOT_TRACK = 1;
  };
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
        alias ls='eza --icons=always --group-directories-first --long --header --octal-permissions --classify --group --extended'
        alias l='l -alh'
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
    eza
    htop
  ];
}
