{ config, ... }:
{
  programs.vim.extraConfig = # vim
    ''
      set viminfo+=n${config.xdg.stateHome}/.viminfo
    '';
}
