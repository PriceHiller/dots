{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };

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
